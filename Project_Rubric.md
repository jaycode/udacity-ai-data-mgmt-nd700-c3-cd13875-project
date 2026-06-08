# Project Rubric: Troubleshoot and Optimize a Multi-Tier AWS Application

## Grading Overview

This project is graded on a **pass/fail** basis.

| Tier | Requirement | Outcome |
|------|-------------|---------|
| **MVP (Required)** | All MVP rubric items must be satisfied | Required to pass |
| **Stretch Goals (Optional)** | Additional criteria for advanced work | Not required to pass; noted in feedback |

---

## Part 1: Implement Comprehensive Observability

### MVP Requirements (Required)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **Structured JSON logging** | Screenshots showing JSON-formatted log entries in CloudWatch Logs for at least one Lambda function. Log entries must include: timestamp, log level, service name, and contextual data. | Verify the log format is valid JSON, not string concatenation. Look for proper field names and consistent structure. |
| **X-Ray tracing on Lambda** | X-Ray service map screenshot showing Lambda functions with active tracing enabled. | Verify traces show Lambda execution details including subsegments for SDK calls. |
| **Custom EMF metrics** | CloudWatch Metrics screenshot showing at least 2 custom metrics appearing in a custom namespace. | Verify metrics are queryable in CloudWatch Metrics console. Check that metric values make sense. |
| **Basic operational dashboard** | Dashboard screenshot showing at least 3 widgets: request/error rates, latency, and one custom metric. | Dashboard should provide at-a-glance visibility into Lambda health. |

### Stretch Goals (Optional)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **Correlation ID propagation** | Screenshots showing correlation ID present in logs across multiple services for the same request. | Check that the same correlation ID appears in API Gateway, Lambda, and downstream services. |
| **X-Ray annotations/metadata** | X-Ray trace screenshot showing custom annotations (user_id, order_id) and metadata. | Annotations must be visible and searchable. Metadata should contain debugging context. |
| **Trace SNS/SQS flows** | X-Ray traces showing message propagation through SNS/SQS to consumer functions. | Should be able to follow a message from producer to consumer. |
| **Enhanced metrics** | Multiple metric types (4+) with multiple dimensions (2+). | Check dimension cardinality is reasonable. |
| **Enhanced dashboard** | Dashboard with metrics widgets, log insights widgets, and alarm status covering all service layers. | Look for holistic view across compute, data, and integration layers. |

---

## Part 2: Diagnose and Fix Application Issues

### MVP Requirements (Required)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **Logs Insights queries** | At least 2 Logs Insights queries showing error identification. Must include actual queries and explanation of findings. | Queries should use appropriate functions (filter, parse, stats). Simple `fields *` queries do not demonstrate skill. |
| **Lambda debugging** | Documentation of Lambda issue identification using CloudWatch Logs, including error type and stack trace analysis. | Student should demonstrate ability to find specific invocations and correlate with request context. |
| **X-Ray trace analysis** | X-Ray trace screenshot showing analysis of at least one issue, identifying slow or failing operations. | Trace should show timing breakdown. Student should identify which specific operations are problematic. |
| **Issue documentation** | Documentation of at least 2 distinct issues with: symptoms, root cause, fix applied, and verification evidence. | Each issue should be clearly different. Fixes must address actual root cause. |
| **Fix verification** | Evidence (logs, metrics, or traces) showing that fixes resolved the identified issues. | Before/after comparison should show measurable improvement. |

### Stretch Goals (Optional)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **SNS/SQS message flow** | Analysis including DLQ inspection and message format validation. | Should demonstrate understanding of async patterns and failure modes. |
| **EventBridge debugging** | Documentation of rule issue with event pattern analysis and correction. | Show before/after event pattern. Rule correction should be specific and verifiable. |
| **Log-trace correlation** | Documentation showing correlation of logs with X-Ray traces using correlation ID or request ID. | Must demonstrate actual correlation technique, not just viewing both separately. |

---

## Part 3: Optimize Performance and Implement Caching

### MVP Requirements (Required)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **Performance profiling** | X-Ray traces showing identification of slowest operations/subsegments with quantified latency. | Must identify specific slow operations, not just overall slow traces. |
| **Lambda memory analysis** | CloudWatch metrics showing Lambda duration and memory usage analysis with optimization recommendations. | Recommendations should be data-driven based on actual metrics. |
| **Lambda optimization** | Before/after metrics showing memory adjustment impact on cost or performance. | Memory choice should be justified with data showing cost/performance tradeoff. |
| **ElastiCache integration** | Code snippet and evidence (logs/metrics) showing cache integration working. | Cache operations should be visible in logs or metrics. Verify Redis connection. |
| **Caching pattern** | Documentation of cache-aside pattern implementation with appropriate TTLs. | TTL should be justified. Pattern should be appropriate for the use case. |
| **Cache verification** | Evidence of cache hits/misses (logs or metrics showing caching is active). | Should show measurable cache activity. |

### Stretch Goals (Optional)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **Database query profiling** | DynamoDB consumed capacity analysis showing identification of inefficient access patterns. | Should show specific query patterns that need optimization. |
| **CloudFront configuration** | Cache behavior settings showing appropriate behaviors for static content types (HTML, JS, CSS, images). | Configuration should make sense for static assets being served. |
| **CloudFront TTLs** | TTL configuration with justification for static content types. | TTLs should be reasonable (not causing excessive misses or stale content). |
| **Cache hit monitoring** | Cache hit rate metrics showing caching effectiveness. | Should show measurable improvement in hit rate or reduced origin requests. |
| **SNS filter policies** | Filter policy JSON showing message filtering logic with evidence of reduced processing. | Filter syntax must be correct. Should filter on appropriate message attributes. |

---

## Part 4: Configure Monitoring, Alerts, and Health Checks

### MVP Requirements (Required)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **Health endpoint** | AWS Lambda invoke output or screenshot showing health endpoint response with dependency check. | Health endpoint should check at least one dependency (database or cache), not just return 200 OK. |
| **CloudWatch alarms** | Screenshot showing at least 3 alarms covering different failure scenarios. | Alarms should cover critical failure modes (Lambda errors, Lambda duration, DynamoDB throttling, etc.). |
| **Alarm thresholds** | Alarm configuration showing thresholds with brief justification. | Thresholds should be reasonable, not arbitrary values. |
| **SNS notification topic** | SNS topic with subscription showing alarm notification configuration. | Should demonstrate notification setup connected to alarms. |
| **Notification test** | Confirmation that test notification was received (email screenshot or confirmation). | Verify subscription is confirmed and delivery works. |

### Stretch Goals (Optional)

| Criteria | Submission Requirements | Reviewer Tip |
|----------|------------------------|--------------|
| **Composite alarms** | Composite alarm configuration or tiered alerting (warning vs critical). | Should demonstrate understanding of alert fatigue and actionable alerting principles. |
| **EventBridge rules** | EventBridge rule showing event pattern matching for operational events. | Rule should capture meaningful events and integrate with notification workflow. |
| **SLI/SLO dashboard** | Dashboard showing availability, latency, error rate with SLO targets indicated. | SLIs should measure customer-facing service health. Targets should be realistic. |
| **Resource utilization** | Analysis of Lambda and DynamoDB resource utilization with capacity planning recommendations. | Analysis should be data-driven and consider cost-performance tradeoffs. |

---

## Submission Guidelines

### Screenshot Naming Convention

All screenshots must follow this standardized naming pattern:

```
Project_Pt_X_screenshot_Y.png
```

Where:
- **X** = Part number (1-4)
- **Y** = Screenshot number within that part (sequential)

**Examples**: `Project_Pt_1_screenshot_1.png`, `Project_Pt_2_screenshot_3.png`

#### Required Screenshots by Part

| Part | Screenshot | Description |
|------|------------|-------------|
| 1 | `Project_Pt_1_screenshot_1.png` | CloudWatch Logs showing JSON structured logs |
| 1 | `Project_Pt_1_screenshot_2.png` | X-Ray service map with Lambda traces |
| 1 | `Project_Pt_1_screenshot_3.png` | CloudWatch Metrics showing custom EMF metrics |
| 1 | `Project_Pt_1_screenshot_4.png` | Operational dashboard with 3+ widgets |
| 2 | `Project_Pt_2_screenshot_1.png` | Logs Insights query results |
| 2 | `Project_Pt_2_screenshot_2.png` | X-Ray trace showing issue root cause |
| 2 | `Project_Pt_2_screenshot_3.png` | Lambda memory before/after metrics |
| 2 | `Project_Pt_2_screenshot_4.png` | Log volume comparison (DEBUG vs INFO) |
| 2 | `Project_Pt_2_screenshot_5.png` | DLQ message inspection |
| 3 | `Project_Pt_3_screenshot_1.png` | X-Ray trace with performance bottlenecks |
| 3 | `Project_Pt_3_screenshot_2.png` | Lambda memory optimization comparison |
| 3 | `Project_Pt_3_screenshot_3.png` | ElastiCache integration (cache hit/miss logs) |
| 4 | `Project_Pt_4_screenshot_1.png` | Health endpoint response |
| 4 | `Project_Pt_4_screenshot_2.png` | CloudWatch alarms configuration |
| 4 | `Project_Pt_4_screenshot_3.png` | SNS notification email received |

Additional screenshots for stretch goals should continue the sequence (e.g., `Project_Pt_1_screenshot_5.png` for Part 1 stretch goal screenshots).

### Required Format

1. **Screenshots** must be clearly legible with relevant portions visible and follow the naming convention above
2. **Code snippets** must be in code blocks or syntax-highlighted
3. **Documentation** must clearly explain what was done and why
4. **Before/after comparisons** must include timestamps or version indicators

### Automatic Fail Conditions

- Plagiarized or copied solutions from other students
- Screenshots from a different AWS account than assigned
- Missing any required MVP deliverable from the checklist
- Evidence of running destructive commands outside project scope
- Solutions that do not address the actual issues (e.g., just increasing timeout without fixing root cause)

### Submission Package

Students should submit a single document or compressed folder containing:
1. All screenshots organized by part (Part 1, Part 2, etc.)
2. Written documentation of issues found and fixes applied
3. Code snippets for key implementations
4. Any exported configurations (alarm definitions, filter policies, etc.)
5. Clear indication of which stretch goals were attempted (if any)

---

## Reviewer Notes

### Time Expectations

| Part | MVP (Required) | With Stretch Goals |
|------|----------------|-------------------|
| Part 1: Observability | 60-75 min | 90-120 min |
| Part 2: Debugging | 60-75 min | 90-120 min |
| Part 3: Optimization | 45-60 min | 60-90 min |
| Part 4: Monitoring | 30-45 min | 45-60 min |
| **Total** | **3-4 hours** | **4-6 hours** |

### Evaluation Process

1. **First**: Verify all MVP requirements are met
   - If any MVP item is missing or inadequate, request revision
   - Be specific about what is missing and reference the rubric criteria

2. **Then**: Review completed stretch goals (if any)
   - Note which stretch goals were completed
   - Provide positive feedback on advanced work
   - Stretch goal gaps do not require revision

### Common Issues to Watch For

**MVP-Level Issues (Require Revision)**
1. **Partial implementations**: Student enables X-Ray on Lambda but not verifying traces
2. **Surface-level fixes**: Increasing timeout without identifying root cause
3. **Missing evidence**: Claims fix worked but no before/after comparison
4. **Insufficient issue count**: Less than 3 documented issues in Part 2
5. **No cache verification**: ElastiCache "integrated" but no evidence it's being used

**Stretch Goal Quality (Feedback Only)**
1. **Missing correlation**: Logs exist but correlation IDs don't propagate
2. **Over-caching**: Student caches everything without considering cache invalidation
3. **Alert spam**: Too many alarms at too sensitive thresholds

### Providing Feedback

**For MVP Revisions:**
- Be specific about what is missing or incorrect
- Reference the relevant MVP rubric criteria
- Suggest resources from the course lessons for guidance
- Acknowledge what was done correctly

**For Stretch Goal Feedback:**
- Acknowledge the additional effort
- Provide constructive feedback on implementation quality
- Note any particularly impressive work
- Suggest improvements without requiring revision

### Sample Feedback Templates

**Passing with MVP Only:**
> Your submission meets all MVP requirements. Your structured logging implementation is well-done, and you clearly documented the issues you found. To go further, consider implementing correlation IDs to make cross-service debugging easier.

**Passing with Stretch Goals:**
> Excellent work! You've completed all MVP requirements and demonstrated advanced competency by completing [X stretch goals]. Your SLI/SLO dashboard shows a strong understanding of production monitoring practices.

**Requires Revision:**
> Your submission is close but needs revision in the following areas:
> - Part 2: Only 2 issues documented (3 required). Please identify and document one additional issue.
> - Part 3: ElastiCache integration shown, but no evidence of cache hits/misses. Please add logs or metrics showing the cache is being used.
