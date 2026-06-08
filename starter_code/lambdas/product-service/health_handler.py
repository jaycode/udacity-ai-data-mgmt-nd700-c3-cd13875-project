"""Health endpoint for the ShopFast product service."""

import json
import os
from datetime import datetime, timezone

import boto3

import cache_service


PRODUCTS_TABLE = os.environ.get("PRODUCTS_TABLE", "shopfast-products-dev")
dynamodb = boto3.client("dynamodb")


def lambda_handler(event, context):
    dependencies = {
        "dynamodb": check_dynamodb(),
        "redis": "connected" if cache_service.ping() else "unavailable",
    }
    healthy = dependencies["dynamodb"] == "connected" and dependencies["redis"] == "connected"

    return {
        "statusCode": 200 if healthy else 503,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": json.dumps(
            {
                "status": "healthy" if healthy else "degraded",
                "dependencies": dependencies,
                "timestamp": now_iso(),
            }
        ),
    }


def check_dynamodb():
    try:
        dynamodb.describe_table(TableName=PRODUCTS_TABLE)
        return "connected"
    except Exception:
        return "unavailable"


def now_iso():
    return datetime.now(timezone.utc).isoformat(timespec="milliseconds").replace("+00:00", "Z")
