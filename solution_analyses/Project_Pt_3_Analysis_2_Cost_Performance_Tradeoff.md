# Cost Performance Tradeoff

The Lambda memory setting was raised from 128 MB to 256 MB. This slightly increases the price per millisecond, but it also gives the function more CPU and network throughput. For this workload, that tradeoff is reasonable because the original timeout risk was more costly to the customer experience than the small increase in per-invocation compute cost.

The timeout was raised from 3 seconds to 10 seconds to stop normal product list requests from failing while still preserving a bounded failure window. The timeout is not a substitute for optimization; it is paired with removal of artificial delays and Redis caching for repeated single-product reads.

Redis caching reduces repeated DynamoDB reads. For frequently viewed products, the extra ElastiCache cost is justified by lower latency, lower DynamoDB read pressure, and fewer customer-facing slow responses.
