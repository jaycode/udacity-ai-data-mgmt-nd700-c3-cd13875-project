# Alarm Threshold Justification

The alarm thresholds are intentionally conservative for a lab environment.

| Alarm | Threshold | Reason |
| --- | --- | --- |
| `ShopFast-dev-ProductService-Errors` | 1 or more Lambda errors in 1 minute | Any product-service error in the lab should be investigated because traffic is low and the endpoint is customer-facing |
| `ShopFast-dev-ProductService-Duration` | Average duration >= 8000 ms for 2 evaluation periods | The function timeout is 10 seconds, so 8 seconds warns before requests begin timing out |
| `ShopFast-dev-DynamoDB-Throttling` | 1 or more read throttle events in 1 minute | The products table has low provisioned capacity; throttling directly affects product page latency |

In production these thresholds should be tuned after collecting a longer baseline. For the project, they demonstrate alerting on customer-impacting errors, latency risk, and data-store capacity pressure.
