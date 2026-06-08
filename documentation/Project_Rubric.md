# Project Rubric: Troubleshoot and Optimize a Multi-Tier AWS Application

## Grading Overview

This project is graded on a **pass/fail** basis.

| Tier | Requirement | Outcome |
|------|-------------|---------|
| **MVP (Required)** | All MVP rubric items must be satisfied | Required to pass |
| **Stretch Goals (Optional)** | Additional criteria for advanced work | Not required to pass; noted in feedback |

---

## AWS Resource Names Reference

| Resource Type | Name |
|---------------|------|
| Lambda Functions | `shopfast-product-service-dev`, `shopfast-notification-handler-dev` |
| Dashboard | "ShopFast-MVP-Dashboard" |
| Metrics Namespace | `ShopFast/Application` |
| DynamoDB Table | `shopfast-products-dev` |

| SNS Topics | `shopfast-product-events-dev`, `shopfast-notifications-dev` |
| SQS DLQ | `shopfast-product-processing-dlq-dev` |
| EventBridge Bus | `shopfast-events-dev` |
| Alarms | `ShopFast-dev-ProductService-Errors`, `ShopFast-dev-ProductService-Duration`, `ShopFast-dev-DynamoDB-Throttling` |
| ElastiCache | `shopfast-redis-dev` |

---

## Part 1: Implement Comprehensive Observability

### MVP Requirements (Required)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Implement structured JSON logging** - At the end of the project, the learner will be able to implement structured JSON logging on Lambda functions in order to enable efficient log analysis in production. | `Project_Pt_1_Screenshot_1_Structured_JSON_Logging.png`: CloudWatch Logs console showing log group `/aws/lambda/shopfast-product-service-dev` with JSON entries containing `timestamp`, `level`, `service`, `message` fields. **Code:** Your modified `handler.py` showing structured logging function. |
| **Enable X-Ray distributed tracing** - At the end of the project, the learner will be able to enable X-Ray tracing on Lambda functions in order to visualize request flows and identify bottlenecks. | `Project_Pt_1_Screenshot_2_XRay_Service_Map.png`: X-Ray service map showing `shopfast-product-service-dev` with downstream services (DynamoDB, SNS) and subsegments for SDK calls visible. **Config:** `template.yaml` with `Tracing: Active`. |
| **Publish custom EMF metrics** - At the end of the project, the learner will be able to publish custom metrics using EMF in order to track application-specific KPIs. | `Project_Pt_1_Screenshot_3_Custom_EMF_Metrics.png`: CloudWatch Metrics console with namespace `ShopFast/Application` selected, showing the `ProductViews` custom metric with recent data points. (Note: The `Errors` metric only appears after an exception occurs.) **Code:** Your modified `handler.py` showing EMF metric emission function. |
| **Create operational dashboard** - At the end of the project, the learner will be able to create a CloudWatch dashboard in order to provide at-a-glance visibility into application health. | `Project_Pt_1_Screenshot_4_Operational_Dashboard.png`: CloudWatch Dashboard named "ShopFast-MVP-Dashboard" with 3+ widgets visible: (1) Lambda Invocations/Errors, (2) Lambda Duration/Latency, (3) Custom EMF metric. |

### Stretch Goals (Optional)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Propagate correlation IDs** - At the end of the project, the learner will be able to propagate correlation IDs across services in order to enable cross-service request tracing. | `Project_Pt_1_Screenshot_5_Correlation_IDs.png`: CloudWatch Logs showing the SAME correlation ID (UUID format) appearing in entries from API Gateway, `shopfast-product-service-dev`, and `shopfast-notification-handler-dev`. Highlight/circle the matching IDs. |
| **Add X-Ray annotations** - At the end of the project, the learner will be able to add custom X-Ray annotations in order to enable searchable trace filtering. | `Project_Pt_1_Screenshot_6_XRay_Annotations.png`: X-Ray trace details panel with "Annotations" tab open showing `user_id` and `product_id` with actual values (not placeholders). **Code:** Your handler showing X-Ray annotation calls. |
| **Trace async message flows** - At the end of the project, the learner will be able to trace async message flows in order to debug SNS/SQS processing issues. | `Project_Pt_1_Screenshot_7_Async_Message_Trace.png`: X-Ray trace spanning SNS publish to `shopfast-product-events-dev` through to `shopfast-notification-handler-dev` Lambda invocation, with timing visible. |
| **Implement enhanced metrics with dimensions** - At the end of the project, the learner will be able to implement enhanced metrics with multiple dimensions in order to enable fine-grained performance analysis. | `Project_Pt_1_Screenshot_8_Enhanced_Metrics.png`: CloudWatch Metrics showing 4+ metric types with 2+ dimensions visible (e.g., `operation=GetProduct`, `status_code=200`). **Code:** Your handler showing EMF with multiple dimensions. |
| **Create enhanced operational dashboard** - At the end of the project, the learner will be able to create an enhanced dashboard covering all service layers in order to provide comprehensive operational visibility. | `Project_Pt_1_Screenshot_9_Enhanced_Dashboard.png`: Dashboard with widgets covering all layers: Lambda metrics (compute), DynamoDB metrics (data), SNS/SQS metrics (integration), plus Alarm Status widget. |

---

## Part 2: Diagnose and Fix Application Issues

### MVP Requirements (Required)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Write Logs Insights queries** - At the end of the project, the learner will be able to write CloudWatch Logs Insights queries in order to identify and analyze errors efficiently. | `Project_Pt_2_Screenshot_1_Logs_Insights_Query.png`: Logs Insights console showing query with visible query text using `filter`, `parse`, or `stats` (e.g., `filter @message like /ERROR/ | stats count(*) by bin(5m)`). Results must show aggregated or filtered data, not raw log output. |
| **Debug Lambda functions** - At the end of the project, the learner will be able to debug Lambda errors using CloudWatch Logs in order to identify root causes from stack traces. | `Project_Pt_2_Screenshot_2_Lambda_Error_Debug.png`: CloudWatch Logs entry from `/aws/lambda/shopfast-product-service-dev` showing request ID, timestamp, full stack trace, and error type visible. **Analysis:** `solution_analyses/Project_Pt_2_Analysis_1_Lambda_Error_Root_Cause.md` explaining error type, affected code path, and root cause. |
| **Analyze X-Ray traces** - At the end of the project, the learner will be able to analyze X-Ray traces in order to identify slow or failing operations. | `Project_Pt_2_Screenshot_3_XRay_Trace_Analysis.png`: X-Ray trace detail view with timeline expanded, showing segment durations in milliseconds. **Analysis:** `solution_analyses/Project_Pt_2_Analysis_2_XRay_Bottleneck_Identification.md` identifying the slow segment with exact latency value (e.g., "DynamoDB GetItem: 450ms") and explaining why it's problematic. |

| **Document issues** - At the end of the project, the learner will be able to document issues with symptoms, root cause, and fixes in order to create maintainable knowledge bases. | `Project_Pt_2_Screenshot_5_Issue_Documentation.png` (or multiple): Screenshot evidence of symptoms observed. **Analysis:** `solution_analyses/Project_Pt_2_Analysis_4_Issue_Documentation.md` documenting 3+ distinct issues, each with: (1) Symptom, (2) Investigation, (3) Root cause, (4) Fix (reference code diff in `src/` files), (5) Verification. Issues must be different types. |
| **Verify fixes** - At the end of the project, the learner will be able to verify fixes using metrics and logs in order to ensure production reliability. | `Project_Pt_2_Screenshot_6_Before_Fix.png`: Metric/log BEFORE fix with timestamp visible. `Project_Pt_2_Screenshot_7_After_Fix.png`: SAME metric/log AFTER fix with later timestamp. **Analysis:** `solution_analyses/Project_Pt_2_Analysis_5_Fix_Verification.md` stating quantified improvement (e.g., "Errors reduced from 45 to 2 per hour"). |

### Stretch Goals (Optional)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Debug EventBridge rules** - At the end of the project, the learner will be able to debug EventBridge rules in order to fix event routing issues. | `Project_Pt_2_Screenshot_8_EventBridge_Before.png` and `Project_Pt_2_Screenshot_9_EventBridge_After.png`: EventBridge console showing `shopfast-product-updated-dev` rule BEFORE (incorrect pattern) and AFTER (corrected pattern). **Analysis:** `solution_analyses/Project_Pt_2_Analysis_6_EventBridge_Fix.md` explaining the pattern change. |
| **Inspect DLQ messages** - At the end of the project, the learner will be able to inspect DLQ messages in order to understand async processing failures. | `Project_Pt_2_Screenshot_10_DLQ_Inspection.png`: SQS console with `shopfast-product-processing-dlq-dev` queue selected, message body expanded. **Analysis:** `solution_analyses/Project_Pt_2_Analysis_7_DLQ_Failure_Mode.md` explaining failure mode and remediation. |

| **Correlate logs with X-Ray traces** - At the end of the project, the learner will be able to correlate CloudWatch logs with X-Ray traces in order to enable unified request debugging. | `Project_Pt_2_Screenshot_12_Log_Entry.png` and `Project_Pt_2_Screenshot_13_XRay_Trace.png`: Log entry with request ID and X-Ray trace found using that ID. **Analysis:** `solution_analyses/Project_Pt_2_Analysis_9_Log_Trace_Correlation.md` proving the correlation technique. |

---

## Part 3: Optimize Performance and Implement Caching

### MVP Requirements (Required)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Profile performance** - At the end of the project, the learner will be able to profile performance using X-Ray traces in order to identify optimization opportunities. | `Project_Pt_3_Screenshot_1_Performance_Profile.png`: X-Ray trace timeline with all segments visible and durations labeled. **Analysis:** `solution_analyses/Project_Pt_3_Analysis_1_Performance_Recommendations.md` identifying slow operation(s) with exact values (e.g., "DynamoDB GetItem: 450ms") and data-driven recommendations. |
| **Analyze Lambda resources** - At the end of the project, the learner will be able to analyze Lambda memory and duration metrics in order to make data-driven optimization decisions. | `Project_Pt_3_Screenshot_2_Lambda_Metrics.png`: CloudWatch metrics for `shopfast-product-service-dev` showing Duration (average and p99) and MemoryUsed vs MemorySize with specific values visible. **Analysis:** Reference `solution_analyses/Project_Pt_3_Analysis_1_Performance_Recommendations.md` for data-driven recommendations. |
| **Optimize Lambda configuration** - At the end of the project, the learner will be able to optimize Lambda memory configuration in order to balance cost and performance. | `Project_Pt_3_Screenshot_3_Lambda_Before.png` and `Project_Pt_3_Screenshot_4_Lambda_After.png`: Lambda Duration metrics at two different memory configurations. **Analysis:** `solution_analyses/Project_Pt_3_Analysis_2_Cost_Performance_Tradeoff.md` with cost calculation (e.g., "256MB @ 400ms = $X vs 512MB @ 180ms = $Y per invocation"). |
| **Integrate Redis caching** - At the end of the project, the learner will be able to integrate ElastiCache Redis with Lambda in order to reduce database load and improve response times. | `Project_Pt_3_Screenshot_5_Redis_Cache_Logs.png`: CloudWatch Logs showing cache operation messages: `CACHE_HIT`, `CACHE_MISS`, `CACHE_SET` with keys and TTL values visible. **Code:** Your `cache_service.py` showing Redis client initialization with `shopfast-redis-dev` endpoint. |
| **Implement cache-aside pattern** - At the end of the project, the learner will be able to implement cache-aside pattern with TTLs in order to balance freshness with performance. | **Code:** Your `cache_service.py` showing cache-aside implementation (check cache → if miss, fetch from DB → write to cache with TTL). **Analysis:** `solution_analyses/Project_Pt_3_Analysis_3_Cache_TTL_Justification.md` explaining TTL value choice (e.g., "TTL of 300s chosen because product data updates infrequently but must reflect inventory changes within 5 minutes"). |
| **Verify caching** - At the end of the project, the learner will be able to verify caching effectiveness in order to confirm performance improvements. | `Project_Pt_3_Screenshot_6_Cache_Verification.png`: CloudWatch Logs or custom metrics showing cache hit count > 0. If cold-start scenario, include `Project_Pt_3_Screenshot_7_Cache_Hits.png` showing subsequent hits. |

### Stretch Goals (Optional)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Profile DynamoDB queries** - At the end of the project, the learner will be able to profile DynamoDB queries in order to identify inefficient access patterns. | `Project_Pt_3_Screenshot_8_DynamoDB_Metrics.png`: CloudWatch metrics for `shopfast-products-dev` showing ConsumedReadCapacityUnits and ConsumedWriteCapacityUnits. **Analysis:** `solution_analyses/Project_Pt_3_Analysis_4_DynamoDB_Patterns.md` identifying inefficient patterns (e.g., "Scan operations consuming 50 RCU vs Query would use 2 RCU"). |
| **Configure SNS filter policies** - At the end of the project, the learner will be able to configure SNS filter policies in order to reduce unnecessary Lambda invocations. | `Project_Pt_3_Screenshot_9_SNS_Filter_Policy.png`: SNS console showing filter policy JSON for `shopfast-product-events-dev` subscription. **Code:** `src/handlers/` showing message attributes being set on publish. |
| **Configure CloudFront cache behaviors** - At the end of the project, the learner will be able to configure CloudFront cache behaviors in order to optimize content delivery for different asset types. | `Project_Pt_3_Screenshot_10_CloudFront_Behaviors.png`: CloudFront cache behaviors configuration showing path patterns (e.g., `/static/*`, `*.js`) and corresponding TTL settings. |
| **Set CloudFront TTL policies** - At the end of the project, the learner will be able to set CloudFront TTL policies in order to balance cache freshness with performance. | `Project_Pt_3_Screenshot_11_CloudFront_TTLs.png`: CloudFront TTL configuration showing different values for static assets (86400s+), versioned assets (31536000s), and HTML (3600s or shorter). |
| **Monitor cache hit rates** - At the end of the project, the learner will be able to monitor cache hit rates in order to verify caching effectiveness and identify optimization opportunities. | `Project_Pt_3_Screenshot_12_Cache_Hit_Rate.png`: CloudFront statistics showing cache hit rate percentage with specific numbers (e.g., "Hit rate improved from 45% to 78%"). |

---

## Part 4: Configure Monitoring, Alerts, and Health Checks

### MVP Requirements (Required)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Implement health endpoint** - At the end of the project, the learner will be able to implement a health check endpoint in order to enable proactive monitoring. | `Project_Pt_4_Screenshot_1_Health_Endpoint.png`: Lambda invoke output or API response showing JSON body: `{"status": "healthy", "dependencies": {"dynamodb": "connected", "redis": "connected"}}`. **Code:** Your `health_handler.py` showing connectivity checks. |
| **Configure CloudWatch alarms** - At the end of the project, the learner will be able to configure CloudWatch alarms in order to enable automated incident detection. | `Project_Pt_4_Screenshot_2_CloudWatch_Alarms.png`: CloudWatch Alarms console showing all three alarms: `ShopFast-dev-ProductService-Errors`, `ShopFast-dev-ProductService-Duration`, `ShopFast-dev-DynamoDB-Throttling`. Each alarm must show metric name, threshold value, and current state. |
| **Set alarm thresholds** - At the end of the project, the learner will be able to set appropriate alarm thresholds in order to minimize false positives while catching real issues. | `Project_Pt_4_Screenshot_3_Alarm_Thresholds.png`: Alarm configuration details showing thresholds with visible evaluation periods. **Analysis:** `solution_analyses/Project_Pt_4_Analysis_1_Alarm_Threshold_Justification.md` explaining threshold choices (e.g., ">5 errors in 5 minutes based on normal error rate of <1/hour"; "p99 >2500ms when baseline p99 is 800ms"). |
| **Configure SNS notifications** - At the end of the project, the learner will be able to configure SNS topics for notifications in order to enable multi-channel alerting. | `Project_Pt_4_Screenshot_4_SNS_Subscription.png`: SNS topic `shopfast-notifications-dev` showing: (1) Email subscription with "Confirmed" status, (2) CloudWatch Alarm connected via Alarm Actions. |
| **Test notifications** - At the end of the project, the learner will be able to test notification delivery in order to verify alerting works end-to-end. | `Project_Pt_4_Screenshot_5_Notification_Email.png`: Actual email received showing: alarm name, state change (OK→ALARM or ALARM→OK), timestamp, and AWS formatting visible. |

### Stretch Goals (Optional)

| Criteria | Submission Requirements |
|----------|------------------------|
| **Create EventBridge rules for ops events** - At the end of the project, the learner will be able to create EventBridge rules for operational events in order to capture operational events. | `Project_Pt_4_Screenshot_6_EventBridge_Rule.png`: EventBridge rule on `shopfast-events-dev` bus showing event pattern (e.g., `{"source": ["aws.lambda"], "detail-type": ["Lambda Function Invocation Result - Failure"]}`) and target configuration. |
| **Build SLI/SLO dashboard** - At the end of the project, the learner will be able to build an SLI/SLO dashboard in order to measure customer-facing service health. | `Project_Pt_4_Screenshot_7_SLI_SLO_Dashboard.png`: Dashboard showing: (1) Availability metric with target line, (2) Latency p99 with target line, (3) Error rate with target line. Targets should be realistic (99.9%, not 100%). |
| **Configure composite alarms** - At the end of the project, the learner will be able to configure composite alarms or tiered alerting in order to reduce alert fatigue while maintaining incident awareness. | `Project_Pt_4_Screenshot_8_Composite_Alarms.png`: CloudWatch showing composite alarm configuration or tiered alerting (Warning vs Critical thresholds). **Analysis:** `solution_analyses/Project_Pt_4_Analysis_2_Composite_Alarm_Design.md` explaining how this reduces alert fatigue. |
| **Analyze resource utilization** - At the end of the project, the learner will be able to analyze resource utilization metrics in order to make data-driven capacity planning decisions. | `Project_Pt_4_Screenshot_9_Resource_Utilization.png`: CloudWatch metrics showing Lambda concurrent executions, DynamoDB consumed vs provisioned capacity. **Analysis:** `solution_analyses/Project_Pt_4_Analysis_3_Capacity_Planning.md` with recommendations and cost estimates. |
