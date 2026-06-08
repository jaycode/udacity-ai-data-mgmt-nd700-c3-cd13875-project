# Issue Documentation

Three separate issues showed up while testing the product service.

## Issue 1: Product list timeout

**Symptom:** `GET /products` could time out under the original 3 second Lambda timeout.

**Investigation:** CloudWatch Logs showed timeout errors, and the X-Ray trace showed the request spending most of its time inside the product list Lambda path.

**Root cause:** The starter handler added artificial waits around a DynamoDB table scan. That made a normal catalog request slow enough to collide with the short timeout.

**Fix:** Removed the artificial waits in `starter_code/lambdas/product-service/handler.py` and increased the Lambda configuration to 256 MB memory with a 10 second timeout.

**Verification:** The after-fix screenshot shows successful requests with shorter duration and no timeout for the validation invocation.

## Issue 2: Single product lookup used the wrong key

**Symptom:** `GET /products/{id}` failed to return seeded product records.

**Investigation:** The seeded DynamoDB items use `productId`, but the starter handler queried the table with `id`.

**Root cause:** The Lambda request path and the DynamoDB table schema did not agree on the partition key name.

**Fix:** Updated `get_product()` to call DynamoDB with `Key={"productId": product_id}` and kept support for both `id` and `productId` path parameters.

**Verification:** The product detail path returns the seeded item after the code change.

## Issue 3: Redis cache existed but was unused

**Symptom:** Repeated product detail requests kept reading through the product handler without any cache evidence.

**Investigation:** ElastiCache was deployed, but the product Lambda had no Redis client or cache-aside logic.

**Root cause:** The architecture included a cache layer, but the application code never integrated with it.

**Fix:** Added `starter_code/lambdas/product-service/cache_service.py` and used it from `get_product()` to perform `CACHE_MISS`, `CACHE_SET`, and `CACHE_HIT` operations with a 300 second TTL.

**Verification:** The cache screenshots show miss, set, and hit log entries for the same product key.
