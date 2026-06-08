# X-Ray Bottleneck Identification

The slowest segment in the original trace was the product catalog read path. The handler spent most of the request duration in the full product scan and the artificial wait time around that scan. Because the Lambda timeout was only 3 seconds, the function could fail before the scan returned.

The updated implementation enables active X-Ray tracing and instruments boto3 through the AWS X-Ray SDK. This makes the Lambda segment and DynamoDB SDK calls visible in X-Ray. After the fix, the trace should show shorter Lambda duration, visible DynamoDB calls, and no timeout segment for the normal `GET /products` request.

The optimization target is to keep the product list request comfortably under the 10 second timeout while using Redis cache-aside for repeated single-product lookups.
