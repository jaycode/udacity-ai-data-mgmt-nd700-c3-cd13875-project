# Submission Guidelines

## Final Submission Content

Your final submission will be a folder containing:
- Your corrected code repository
- Screenshots demonstrating each achieved objective
- Analysis files documenting your findings and decisions

---

## Folder Structure

```
submission/
├── screenshots/
│   ├── Project_Pt_1_Screenshot_1_Structured_JSON_Logging.png
│   ├── Project_Pt_1_Screenshot_2_XRay_Service_Map.png
│   └── ... (all screenshots)
├── solution_analyses/
│   ├── Project_Pt_2_Analysis_1_Lambda_Error_Root_Cause.md
│   ├── Project_Pt_2_Analysis_2_XRay_Bottleneck_Identification.md
│   └── ... (all analysis files)
└── code/
    └── (corrected codebase)
```

---

## Screenshot Naming Convention

All screenshots must follow this standardized naming pattern:

```
Project_Pt_X_Screenshot_Y_Descriptive_Name.png
```

Where:
- **X** = Part number (1-4)
- **Y** = Screenshot number within that part (sequential)
- **Descriptive_Name** = Brief description of what the screenshot shows

**Examples**: `Project_Pt_1_Screenshot_1_Structured_JSON_Logging.png`, `Project_Pt_2_Screenshot_3_XRay_Trace_Analysis.png`

---

## Required Screenshots by Part

### Part 1: Implement Comprehensive Observability

**MVP Screenshots (4 required)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_1_Screenshot_1_Structured_JSON_Logging.png` | CloudWatch Logs with JSON structured logs containing `timestamp`, `level`, `service`, `message` |
| `Project_Pt_1_Screenshot_2_XRay_Service_Map.png` | X-Ray service map with downstream services and subsegments |
| `Project_Pt_1_Screenshot_3_Custom_EMF_Metrics.png` | CloudWatch Metrics namespace `ShopFast/Application` with 2+ metrics |
| `Project_Pt_1_Screenshot_4_Operational_Dashboard.png` | "ShopFast-MVP-Dashboard" with 3+ widgets |

**Stretch Goal Screenshots (Optional)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_1_Screenshot_5_Correlation_IDs.png` | Same correlation ID across multiple services |
| `Project_Pt_1_Screenshot_6_XRay_Annotations.png` | X-Ray trace with custom annotations |
| `Project_Pt_1_Screenshot_7_Async_Message_Trace.png` | X-Ray trace spanning SNS to Lambda |
| `Project_Pt_1_Screenshot_8_Enhanced_Metrics.png` | CloudWatch Metrics with 4+ types and 2+ dimensions |
| `Project_Pt_1_Screenshot_9_Enhanced_Dashboard.png` | Dashboard covering all service layers |

---

### Part 2: Diagnose and Fix Application Issues

**MVP Screenshots (7 required)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_2_Screenshot_1_Logs_Insights_Query.png` | Logs Insights console with query using `filter`, `parse`, or `stats` |
| `Project_Pt_2_Screenshot_2_Lambda_Error_Debug.png` | CloudWatch Logs entry with stack trace visible |
| `Project_Pt_2_Screenshot_3_XRay_Trace_Analysis.png` | X-Ray trace with segment durations visible |
| `Project_Pt_2_Screenshot_5_Issue_Documentation.png` | Evidence for 2+ distinct issues |
| `Project_Pt_2_Screenshot_6_Before_Fix.png` | Metrics/logs BEFORE fix with timestamp |
| `Project_Pt_2_Screenshot_7_After_Fix.png` | Metrics/logs AFTER fix with improvement |

**Stretch Goal Screenshots (Optional)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_2_Screenshot_8_EventBridge_Before.png` | EventBridge rule BEFORE fix |
| `Project_Pt_2_Screenshot_9_EventBridge_After.png` | EventBridge rule AFTER fix |
| `Project_Pt_2_Screenshot_10_DLQ_Inspection.png` | SQS DLQ message inspection |
| `Project_Pt_2_Screenshot_12_Log_Entry.png` | Log entry with request ID |
| `Project_Pt_2_Screenshot_13_XRay_Trace.png` | X-Ray trace for correlation |

---

### Part 3: Optimize Performance and Implement Caching

**MVP Screenshots (6-7 required)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_3_Screenshot_1_Performance_Profile.png` | X-Ray trace with segment durations |
| `Project_Pt_3_Screenshot_2_Lambda_Metrics.png` | CloudWatch Lambda Duration/Memory metrics |
| `Project_Pt_3_Screenshot_3_Lambda_Before.png` | Lambda metrics BEFORE memory optimization |
| `Project_Pt_3_Screenshot_4_Lambda_After.png` | Lambda metrics AFTER memory optimization |
| `Project_Pt_3_Screenshot_5_Redis_Cache_Logs.png` | CloudWatch Logs with CACHE_HIT/MISS/SET |
| `Project_Pt_3_Screenshot_6_Cache_Verification.png` | Cache statistics with hit count > 0 |
| `Project_Pt_3_Screenshot_7_Cache_Hits.png` | (If cold-start) Subsequent cache hits |

**Stretch Goal Screenshots (Optional)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_3_Screenshot_8_DynamoDB_Metrics.png` | DynamoDB consumed capacity |
| `Project_Pt_3_Screenshot_9_SNS_Filter_Policy.png` | SNS filter policy |
| `Project_Pt_3_Screenshot_10_CloudFront_Behaviors.png` | CloudFront cache behaviors |
| `Project_Pt_3_Screenshot_11_CloudFront_TTLs.png` | CloudFront TTL configuration |
| `Project_Pt_3_Screenshot_12_Cache_Hit_Rate.png` | CloudFront cache hit rate |

---

### Part 4: Configure Monitoring, Alerts, and Health Checks

**MVP Screenshots (5 required)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_4_Screenshot_1_Health_Endpoint.png` | Health endpoint response with dependency status |
| `Project_Pt_4_Screenshot_2_CloudWatch_Alarms.png` | CloudWatch Alarms console showing all 3 alarms |
| `Project_Pt_4_Screenshot_3_Alarm_Thresholds.png` | Alarm configuration with thresholds visible |
| `Project_Pt_4_Screenshot_4_SNS_Subscription.png` | SNS topic with confirmed email subscription |
| `Project_Pt_4_Screenshot_5_Notification_Email.png` | Email received from SNS alarm notification |

**Stretch Goal Screenshots (Optional)**

| Screenshot | Description |
|------------|-------------|
| `Project_Pt_4_Screenshot_6_EventBridge_Rule.png` | EventBridge rule for ops events |
| `Project_Pt_4_Screenshot_7_SLI_SLO_Dashboard.png` | SLI/SLO dashboard with target lines |
| `Project_Pt_4_Screenshot_8_Composite_Alarms.png` | Composite alarm configuration |
| `Project_Pt_4_Screenshot_9_Resource_Utilization.png` | Resource utilization metrics |

---

## Required Analysis Files

Analysis files provide written documentation of your findings, decisions, and justifications. Create these as markdown files in the `solution_analyses/` folder.

### MVP Analysis Files (9 required)

| Analysis File | Purpose |
|---------------|---------|
| `Project_Pt_2_Analysis_1_Lambda_Error_Root_Cause.md` | Explain error type, affected code path, root cause |
| `Project_Pt_2_Analysis_2_XRay_Bottleneck_Identification.md` | Identify slow segment with latency and explanation |
| `Project_Pt_2_Analysis_4_Issue_Documentation.md` | Document 3+ issues (symptoms, root cause, fix, verification) |
| `Project_Pt_2_Analysis_5_Fix_Verification.md` | Quantify improvement metrics |
| `Project_Pt_3_Analysis_1_Performance_Recommendations.md` | Data-driven performance recommendations |
| `Project_Pt_3_Analysis_2_Cost_Performance_Tradeoff.md` | Cost calculation for memory optimization |
| `Project_Pt_3_Analysis_3_Cache_TTL_Justification.md` | Cache-aside pattern and TTL choice |
| `Project_Pt_4_Analysis_1_Alarm_Threshold_Justification.md` | Explain threshold choices based on baselines |

### Stretch Goal Analysis Files (Optional)

| Analysis File | Purpose |
|---------------|---------|
| `Project_Pt_2_Analysis_6_EventBridge_Fix.md` | Before/after event pattern explanation |
| `Project_Pt_2_Analysis_7_DLQ_Failure_Mode.md` | Explain DLQ message failure mode |
| `Project_Pt_2_Analysis_9_Log_Trace_Correlation.md` | Prove correlation technique |
| `Project_Pt_3_Analysis_4_DynamoDB_Patterns.md` | Identify inefficient access patterns |
| `Project_Pt_4_Analysis_2_Composite_Alarm_Design.md` | Explain tiered alerting approach |
| `Project_Pt_4_Analysis_3_Capacity_Planning.md` | Resource utilization recommendations |

---

## Required Format

1. **Screenshots** must be:
   - Clearly legible with relevant portions visible
   - Following the naming convention above
   - PNG format recommended
   - Annotated where helpful (circle/highlight key elements)

2. **Code Repository** must include:
   - All fixes applied to the codebase
   - No broken or incomplete implementations

3. **Analysis Files** must include:
   - Specific values and metrics (not vague descriptions)
   - Clear explanations of decisions and trade-offs
   - References to relevant screenshots or code files

4. **Before/after comparisons** must include:
   - Visible timestamps or version indicators
   - Quantified improvement metrics where applicable

---

## Submission Package

Your final submission should be a single compressed folder containing:

1. **Screenshots folder** - All screenshots organized by part (or in a flat structure with proper naming)
2. **Analysis files folder** - All analysis markdown files in `solution_analyses/`
3. **Code repository** - Your corrected codebase with all fixes
4. **Configuration exports** (optional) - Alarm definitions, filter policies, dashboard JSON, etc.
5. **Stretch goals indicator** - Clear indication of which stretch goals were attempted (if any)

---

## Submission Summary

### MVP Requirements
| Part | Screenshots | Analysis Files |
|------|-------------|----------------|
| Part 1 | 4 | 0 |
| Part 2 | 7 | 5 |
| Part 3 | 6-7 | 3 |
| Part 4 | 5 | 1 |
| **Total** | **22-23** | **9** |

### Stretch Goals (Optional)
| Part | Screenshots | Analysis Files |
|------|-------------|----------------|
| Part 1 | 5 | 0 |
| Part 2 | 6 | 4 |
| Part 3 | 5 | 1 |
| Part 4 | 4 | 2 |
| **Total** | **20** | **7** |

---

## Tips for Success

- **Take screenshots as you work** - Don't wait until the end to capture evidence
- **Include timestamps** - Ensure timestamps are visible in before/after comparisons
- **Annotate where helpful** - Circle or highlight key elements in screenshots
- **Be specific in analysis files** - Include exact values, not vague descriptions
- **Test your fixes** - Ensure improvements are measurable before taking final screenshots
- **Use descriptive filenames** - The screenshot name should tell the reviewer what to expect
