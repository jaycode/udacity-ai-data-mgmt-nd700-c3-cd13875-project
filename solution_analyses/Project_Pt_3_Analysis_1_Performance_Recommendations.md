# Performance Recommendations

The largest performance wins are in the product read path.

1. Remove artificial waits and keep the Lambda timeout aligned with observed p99 duration.
2. Use Redis cache-aside for `GET /products/{id}` so repeated product detail views avoid DynamoDB reads.
3. Keep X-Ray active to monitor DynamoDB latency and confirm whether future bottlenecks are application code, network access, or DynamoDB capacity.
4. Track `CacheHits`, `CacheMisses`, `ProductViews`, and `Errors` with EMF so performance and business behavior can be reviewed from the same dashboard.

The implementation focuses on those high-impact changes while keeping the architecture close to the starter project.
