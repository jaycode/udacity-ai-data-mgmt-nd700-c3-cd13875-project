# Lambda Error Root Cause

The primary failure was the product list path, `GET /products`, timing out under the original Lambda settings. The function was configured with a 3 second timeout and 128 MB of memory while the starter code added artificial delays around a full DynamoDB table scan. With even a small amount of pagination, the handler could exceed the timeout before it returned a response.

The error appears as `Task timed out after 3.00 seconds` in CloudWatch Logs for `/aws/lambda/shopfast-product-service-dev`. The impacted code path was `get_all_products()`, which slept before and during scan pagination. The single-product path was affected by a separate correctness issue: the DynamoDB table key is `productId`, but the starter handler used `id`.

Fixes applied:

- Removed artificial sleep calls from the product scan path.
- Increased Lambda timeout from 3 seconds to 10 seconds and memory from 128 MB to 256 MB.
- Corrected single-product DynamoDB reads to use `productId`.
- Added structured error logs and EMF `Errors` metrics so future failures are searchable and measurable.
