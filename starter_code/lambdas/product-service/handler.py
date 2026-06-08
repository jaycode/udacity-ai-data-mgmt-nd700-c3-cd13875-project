"""
Product Service Lambda Handler.

Handles product catalog reads, emits structured logs/EMF metrics, and traces
downstream AWS SDK calls with X-Ray.
"""

import json
import os
import uuid
from datetime import datetime, timezone
from decimal import Decimal

try:
    from aws_xray_sdk.core import patch_all, xray_recorder

    patch_all()
except Exception:  # pragma: no cover - keeps local tooling usable without X-Ray
    xray_recorder = None

import boto3

import cache_service
import health_handler


SERVICE_NAME = "product-service"
ENVIRONMENT = os.environ.get("ENVIRONMENT", "dev")
PRODUCTS_TABLE = os.environ.get("PRODUCTS_TABLE", "shopfast-products-dev")

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(PRODUCTS_TABLE)


class DecimalEncoder(json.JSONEncoder):
    """Handle Decimal values returned by DynamoDB."""

    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj) if obj % 1 == 0 else float(obj)
        return super().default(obj)


def now_iso():
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")


def request_context(context=None, **extra):
    payload = {
        "request_id": getattr(context, "aws_request_id", "local"),
        "service": SERVICE_NAME,
        "environment": ENVIRONMENT,
    }
    payload.update({key: value for key, value in extra.items() if value is not None})
    return payload


def log(level, message, **fields):
    entry = {
        "timestamp": now_iso(),
        "level": level,
        "service": SERVICE_NAME,
        "message": message,
    }
    entry.update({key: value for key, value in fields.items() if value is not None})
    print(json.dumps(entry, cls=DecimalEncoder))


def emit_metric(metric_name, value, unit="Count", **fields):
    metric = {
        "_aws": {
            "Timestamp": int(datetime.now(timezone.utc).timestamp() * 1000),
            "CloudWatchMetrics": [
                {
                    "Namespace": "ShopFast/Application",
                    "Dimensions": [["Service"], ["Service", "Environment"]],
                    "Metrics": [{"Name": metric_name, "Unit": unit}],
                }
            ],
        },
        "Service": SERVICE_NAME,
        "Environment": ENVIRONMENT,
        metric_name: value,
    }
    metric.update({key: value for key, value in fields.items() if value is not None})
    print(json.dumps(metric, cls=DecimalEncoder))


def annotate_trace(**annotations):
    if not xray_recorder:
        return
    for key, value in annotations.items():
        if value is None:
            continue
        try:
            xray_recorder.put_annotation(key, str(value))
        except Exception:
            pass


def lambda_handler(event, context):
    """
    Main Lambda handler for product operations.

    Routes:
    - GET /products
    - GET /products/{id}
    - GET /health
    """
    http_method = event.get("httpMethod") or event.get("requestContext", {}).get("http", {}).get("method", "")
    path = event.get("path") or event.get("rawPath", "")
    path_parameters = event.get("pathParameters") or {}
    correlation_id = (
        (event.get("headers") or {}).get("X-Correlation-Id")
        or (event.get("headers") or {}).get("x-correlation-id")
        or str(uuid.uuid4())
    )

    base_context = request_context(
        context,
        correlation_id=correlation_id,
        http_method=http_method,
        path=path,
    )

    log("INFO", "Request received", **base_context)
    annotate_trace(path=path, method=http_method, correlation_id=correlation_id)

    try:
        if http_method == "GET" and path == "/health":
            return health_handler.lambda_handler(event, context)

        if http_method == "GET" and path == "/products":
            emit_metric("ProductViews", 1, operation="list_products")
            emit_metric("Errors", 0, operation="list_products")
            return get_all_products(base_context)

        product_id = resolve_product_id(path, path_parameters)
        if http_method == "GET" and product_id:
            annotate_trace(product_id=product_id)
            emit_metric("ProductViews", 1, operation="get_product")
            response = get_product(product_id, base_context)
            if response["statusCode"] < 500:
                emit_metric("Errors", 0, operation="get_product")
            return response

        emit_metric("Errors", 1, operation="not_found")
        log("WARN", "Route not found", **base_context)
        return json_response(404, {"error": "Not found", "correlation_id": correlation_id})

    except Exception as exc:
        emit_metric("Errors", 1, operation="exception")
        log("ERROR", "Unhandled product service error", error_type=type(exc).__name__, error=str(exc), **base_context)
        return json_response(500, {"error": "Internal server error", "correlation_id": correlation_id})


def resolve_product_id(path, path_parameters):
    product_id = path_parameters.get("id") or path_parameters.get("productId")
    if product_id:
        return product_id
    if path.startswith("/products/"):
        return path.rsplit("/", 1)[-1]
    return None


def get_all_products(context_fields):
    """Retrieve all products from DynamoDB without artificial delays."""
    log("INFO", "Fetching all products from DynamoDB", **context_fields)

    response = table.scan()
    products = response.get("Items", [])

    while "LastEvaluatedKey" in response:
        response = table.scan(ExclusiveStartKey=response["LastEvaluatedKey"])
        products.extend(response.get("Items", []))

    log("INFO", "Products fetched", product_count=len(products), **context_fields)
    return json_response(200, products)


def get_product(product_id, context_fields):
    """Retrieve a single product by ID, using Redis as a cache-aside store."""
    cache_key = f"product:{product_id}"
    log("INFO", "Fetching product", product_id=product_id, **context_fields)

    cached_product = cache_service.get_json(cache_key)
    if cached_product is not None:
        emit_metric("CacheHits", 1, operation="get_product")
        log("INFO", "CACHE_HIT", product_id=product_id, cache_key=cache_key, **context_fields)
        return json_response(200, cached_product)

    emit_metric("CacheMisses", 1, operation="get_product")
    log("INFO", "CACHE_MISS", product_id=product_id, cache_key=cache_key, **context_fields)

    response = table.get_item(Key={"productId": product_id})
    product = response.get("Item")

    if not product:
        emit_metric("Errors", 1, operation="product_not_found")
        log("WARN", "Product not found", product_id=product_id, **context_fields)
        return json_response(404, {"error": "Product not found", "productId": product_id})

    if cache_service.set_json(cache_key, product):
        log(
            "INFO",
            "CACHE_SET",
            product_id=product_id,
            cache_key=cache_key,
            ttl_seconds=cache_service.CACHE_TTL_SECONDS,
            **context_fields,
        )

    return json_response(200, product)


def json_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": get_cors_headers(),
        "body": json.dumps(body, cls=DecimalEncoder),
    }


def get_cors_headers():
    """Return response headers.

    The Lambda Function URL owns CORS headers for browser requests. Returning
    CORS here as well creates duplicate Access-Control-Allow-Origin values.
    """
    return {
        "Content-Type": "application/json",
    }
