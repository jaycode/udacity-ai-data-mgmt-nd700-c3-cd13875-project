"""Redis cache helper for the ShopFast product service."""

import json
import os
from decimal import Decimal

try:
    import redis
except ImportError:  # pragma: no cover - local syntax checks may not install deps
    redis = None


REDIS_ENDPOINT = os.environ.get("REDIS_ENDPOINT") or os.environ.get("REDIS_HOST")
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))
CACHE_TTL_SECONDS = int(os.environ.get("CACHE_TTL_SECONDS", "300"))

_client = None


def _json_default(value):
    if isinstance(value, Decimal):
        return int(value) if value % 1 == 0 else float(value)
    raise TypeError(f"Object of type {type(value).__name__} is not JSON serializable")


def get_client():
    global _client
    if _client is not None:
        return _client
    if redis is None or not REDIS_ENDPOINT:
        return None

    _client = redis.Redis(
        host=REDIS_ENDPOINT,
        port=REDIS_PORT,
        socket_connect_timeout=1,
        socket_timeout=1,
        decode_responses=True,
    )
    return _client


def get_json(key):
    client = get_client()
    if client is None:
        return None

    try:
        value = client.get(key)
    except Exception:
        return None

    if value is None:
        return None
    return json.loads(value)


def set_json(key, value, ttl_seconds=CACHE_TTL_SECONDS):
    client = get_client()
    if client is None:
        return False

    try:
        client.setex(key, ttl_seconds, json.dumps(value, default=_json_default))
        return True
    except Exception:
        return False


def ping():
    client = get_client()
    if client is None:
        return False

    try:
        return bool(client.ping())
    except Exception:
        return False
