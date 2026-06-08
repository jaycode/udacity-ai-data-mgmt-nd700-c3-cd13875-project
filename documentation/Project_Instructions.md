# Final Project: Troubleshoot and Optimize a Serverless AWS Application

## Project Overview

### The Challenge

It's 2 AM and your phone is buzzing with alerts. ShopFast, a rapidly growing e-commerce startup, is experiencing their worst nightmare during Black Friday weekend.

**ShopFast** has grown from a small online retailer to processing over 50,000 orders daily. Their engineering team worked around the clock to scale their AWS infrastructure for the holiday rush, but the hastily assembled system is now falling apart. Customers are reporting slow page loads, failed API calls, and missing notifications. The CEO is demanding answers.

As a **Senior DevOps Consultant**, the CTO has brought you in to save their platform. You'll find a serverless application built with Lambda, API Gateway, and DynamoDB. The previous team left minimal documentation, inconsistent logging, and no centralized monitoring.

Your mission? Bring order to chaos. Implement proper observability, identify and fix the issues plaguing the platform, optimize performance, and build production-grade monitoring before the next traffic surge.

### Why This Project Matters

This project puts you in a realistic scenario faced by cloud engineers at companies of all sizes. You will:

- **Implement Observability**: Transform a poorly instrumented application into a fully observable system
- **Debug Under Pressure**: Use logs, metrics, and traces to identify root causes of production issues
- **Optimize for Performance**: Profile bottlenecks and implement caching strategies that reduce latency by 50%+
- **Build for Production**: Create monitoring and alerting that will catch problems before customers do

If you're ready to tackle a real-world challenge, let's begin.

---

## Project Structure

This project is organized into two tiers:

| Tier | Description | Time Estimate |
|------|-------------|---------------|
| **MVP (Required)** | Core tasks that demonstrate fundamental competency | 3-4 hours |
| **Stretch Goals (Optional)** | Advanced tasks for those who want to go deeper | 1-2 additional hours |

**To pass this project, you must complete all MVP requirements.** Stretch goals are optional and provide opportunities to demonstrate advanced skills.

---

## Environment Overview

### Application Architecture

ShopFast's e-commerce platform is built entirely on serverless AWS services:

**Frontend Layer**
- CloudFront distribution serving a React single-page application
- Lambda functions invoked via AWS SDK/CLI

**Application Layer**
- **Product Service**: Lambda functions (Python) serving the product catalog
- **Notification Service**: Lambda function processing SNS/SQS notifications

**Data Layer**
- DynamoDB for product catalog (high-read workload)
- ElastiCache Redis (deployed but not integrated)
- S3 for static assets and product images

**Integration Layer**
- SNS topics for product events and notifications
- SQS queues for async processing with dead-letter queues
- EventBridge for cross-service event routing

### Pre-Deployed Resources

All infrastructure is provisioned and ready. See the **Environment Setup Guide** for:
- Complete resource inventory
- Access credentials and CLI configuration
- Initial verification commands
- Known gaps in the current state

### Running AWS CLI Commands

All AWS CLI verification commands in this project should be run from the **AWS Cloud9 IDE** provided in your lab environment. Cloud9 provides:
- Pre-configured AWS CLI with proper credentials
- VPC connectivity to access ElastiCache Redis
- Built-in terminal for running commands

To access Cloud9:
1. Navigate to AWS Console > Cloud9
2. Open the `shopfast-dev` environment
3. Use the terminal at the bottom of the IDE to run commands

---

## Submitting Your Work

### Folder Structure

As you complete this project, save your deliverables in the following folders:

- **Screenshots**: Save all screenshots to the `screenshots/` folder in the project root
- **Analysis Files**: Save all analysis markdown files to the `solution_analyses/` folder in the project root
- **Code**: Your code changes will be in `starter_code/`

### Final Submission

When you have completed all MVP requirements:
1. Ensure all screenshots are in the `screenshots/` folder with the exact filenames specified in each task
2. Ensure all analysis files are in the `solution_analyses/` folder with the exact filenames specified
3. Verify your code changes are saved in `starter_code/`
4. Zip your entire project folder
5. Submit the zip file via the Udacity project submission console

---

## Instructions

### Part 1: Implement Comprehensive Observability

**MVP Time Estimate**: 60-75 minutes | **With Stretch Goals**: 90-120 minutes

#### Situation

The ShopFast engineering team deployed services quickly without proper instrumentation. Lambda functions use basic `print()` statements. There's no distributed tracing, no custom metrics, and no operational dashboards. When issues occur, the team spends hours manually correlating logs across services.

#### Objectives

Transform the under-instrumented application into a fully observable system.

---

### MVP Requirements (Required)

**1. Implement Structured Logging**

**Problem:** The product service uses basic `print()` statements making logs hard to search and correlate. Check CloudWatch Logs at `/aws/lambda/shopfast-product-service-dev` to see the current unstructured output (e.g., `Received event: {...}`, `Fetching all products...`).

**Task:** Update the `shopfast-product-service-dev` Lambda function to implement structured JSON logging with:
- Timestamp in ISO 8601 format
- Log level (INFO, WARN, ERROR)
- Service name (`product-service`)
- Contextual data (request ID, product ID as appropriate)

**How to Deploy Your Changes:**

You can deploy your code changes using either method:

*Option A - Edit directly in Lambda Console:*
1. Navigate to AWS Console > Lambda > Functions > `shopfast-product-service-dev`
2. In the Code tab, edit `handler.py` directly in the code editor
3. Click **Deploy** to save and deploy your changes

*Option B - Edit in Cloud9 and deploy via CLI:*
1. Edit the file `starter_code/lambdas/product-service/handler.py` in Cloud9
2. Zip and deploy with AWS CLI:
   ```bash
   cd starter_code/lambdas/product-service
   zip -r function.zip .
   aws lambda update-function-code \
     --function-name shopfast-product-service-dev \
     --zip-file fileb://function.zip
   ```

**Verification:**

Run the following command in Cloud9 to invoke the Lambda and generate logs:

```bash
aws lambda invoke --function-name shopfast-product-service-dev \
  --payload '{"httpMethod": "GET", "path": "/products"}' \
  --cli-binary-format raw-in-base64-out output.json
```

Then check recent logs for JSON format:

```bash
aws logs filter-log-events \
  --log-group-name /aws/lambda/shopfast-product-service-dev \
  --limit 5
```

**What WRONG looks like:**
- Plain text: `Received event: {"httpMethod": "GET"...}` (unstructured)
- NameError in logs: `NameError: name 'datetime' is not defined` (missing import)

**What CORRECT looks like:**
```json
{"timestamp": "2024-01-15T12:00:00.000Z", "level": "INFO", "service": "product-service", "message": "Request received", "path": "/products"}
```

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of the CloudWatch Logs console showing log group `/aws/lambda/shopfast-product-service-dev` with JSON log entries visible. The logs must show `timestamp`, `level`, `service`, and `message` fields. Save it as `screenshots/Project_Pt_1_Screenshot_1_Structured_JSON_Logging.png`

---

**2. Enable X-Ray Tracing on Lambda**

**Problem:** There's no visibility into request flows or downstream service latency. The product service makes calls to DynamoDB, but there's no way to see how long these calls take or where bottlenecks occur.

**Task:** Enable X-Ray active tracing on the `shopfast-product-service-dev` Lambda function.

**How to Deploy Your Changes:**

You can enable X-Ray tracing using either method:

*Option A - Enable directly in Lambda Console:*
1. Navigate to AWS Console > Lambda > Functions > `shopfast-product-service-dev`
2. Go to the **Configuration** tab > **Monitoring and operations tools**
3. Click **Edit**
4. Under **AWS X-Ray**, select **Active tracing**
5. Click **Save**

*Option B - Enable via AWS CLI in Cloud9:*
```bash
aws lambda update-function-configuration \
  --function-name shopfast-product-service-dev \
  --tracing-config Mode=Active
```

**Important:** Enabling `Tracing: Active` on Lambda only captures the Lambda invocation itself. To see downstream service calls (like DynamoDB) in the X-Ray service map, you must also instrument boto3 using the X-Ray SDK. Refer to your earlier lessons on X-Ray SDK integration for how to do this.

**Verification:**

After redeploying with the X-Ray SDK, run the following command in Cloud9 to invoke the Lambda:

```bash
aws lambda invoke --function-name shopfast-product-service-dev \
  --payload '{"httpMethod": "GET", "path": "/products"}' \
  --cli-binary-format raw-in-base64-out output.json
```

Then check the X-Ray console for traces: AWS Console > X-Ray > Traces > Filter by service: `shopfast-product-service-dev`

Look for: Service map showing `shopfast-product-service-dev` with connections to downstream services (DynamoDB).

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of the X-Ray service map showing `shopfast-product-service-dev` with connections to downstream services (DynamoDB). Save it as `screenshots/Project_Pt_1_Screenshot_2_XRay_Service_Map.png`

---

**3. Implement Basic Custom Metrics**

**Problem:** There are no application-level metrics to track business KPIs like product views or error rates. CloudWatch only shows Lambda system metrics (invocations, duration, errors) but not what the application is actually doing.

**Task:** Update the `shopfast-product-service-dev` Lambda function to publish custom metrics using CloudWatch Embedded Metric Format (EMF):
- `ProductViews` - Count of product page views
- `Errors` - Count of application errors

Metrics should be published to the `ShopFast/Application` namespace with a `Service` dimension set to `product-service`.

**How to Deploy Your Changes:**

You can deploy your code changes using either method:

*Option A - Edit directly in Lambda Console:*
1. Navigate to AWS Console > Lambda > Functions > `shopfast-product-service-dev`
2. In the Code tab, edit `handler.py` directly in the code editor
3. Click **Deploy** to save and deploy your changes

*Option B - Edit in Cloud9 and deploy via CLI:*
1. Edit the file `starter_code/lambdas/product-service/handler.py` in Cloud9
2. Zip and deploy with AWS CLI:
   ```bash
   cd starter_code/lambdas/product-service
   zip -r function.zip .
   aws lambda update-function-code \
     --function-name shopfast-product-service-dev \
     --zip-file fileb://function.zip
   ```

**Verification:**

After deploying your changes, run the following command in Cloud9 to invoke the Lambda several times:

```bash
for i in {1..5}; do
  aws lambda invoke --function-name shopfast-product-service-dev \
    --payload '{"httpMethod": "GET", "path": "/products"}' \
    --cli-binary-format raw-in-base64-out output.json
done
```

Wait 1-2 minutes for metrics to appear, then check: AWS Console > CloudWatch > Metrics > Custom Namespaces > ShopFast/Application

Look for: Custom metrics `ProductViews` and `Errors` with the `Service=product-service` dimension.

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of the CloudWatch Metrics console with namespace `ShopFast/Application` selected, showing at least 2 custom metrics (`ProductViews` and `Errors`) with the `Service=product-service` dimension. Save it as `screenshots/Project_Pt_1_Screenshot_3_Custom_EMF_Metrics.png`

---

**4. Build Basic Operational Dashboard**

**Problem:** There's no centralized view of application health. To understand what's happening, you'd have to check Lambda metrics, CloudWatch Logs, and custom metrics separately.

**Task:** Create a CloudWatch dashboard named "ShopFast-MVP-Dashboard" with at least 3 widgets:
1. Lambda Invocations/Errors for `shopfast-product-service-dev`
2. Lambda Duration (P50 latency minimum)
3. At least one custom EMF metric from `ShopFast/Application` namespace

**Verification:**

Run the following command in Cloud9 to verify the dashboard exists:

```bash
aws cloudwatch list-dashboards | grep ShopFast
```

Or view in AWS Console > CloudWatch > Dashboards > ShopFast-MVP-Dashboard

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of your CloudWatch Dashboard named "ShopFast-MVP-Dashboard" with 3+ widgets visible (Lambda Invocations/Errors, Lambda Duration, and at least one custom EMF metric). Save it as `screenshots/Project_Pt_1_Screenshot_4_Operational_Dashboard.png`

---

#### MVP Deliverables

- `screenshots/Project_Pt_1_Screenshot_1_Structured_JSON_Logging.png`: CloudWatch Logs console showing log group `/aws/lambda/shopfast-product-service-dev` with JSON entries containing `timestamp`, `level`, `service`, `message` fields
- `screenshots/Project_Pt_1_Screenshot_2_XRay_Service_Map.png`: X-Ray service map showing `shopfast-product-service-dev` with downstream services (DynamoDB, SNS) and subsegments for SDK calls visible
- `screenshots/Project_Pt_1_Screenshot_3_Custom_EMF_Metrics.png`: CloudWatch Metrics console with namespace `ShopFast/Application` selected, showing at least 2 custom metrics
- `screenshots/Project_Pt_1_Screenshot_4_Operational_Dashboard.png`: CloudWatch Dashboard named "ShopFast-MVP-Dashboard" with 3+ widgets visible
- **Code:** Your modified `starter_code/lambdas/product-service/handler.py` showing structured logging function and EMF metric emission

---

### Stretch Goals (Optional)

**5. Add Correlation ID Propagation**

Implement correlation ID generation and propagation:
- Generate a correlation ID for incoming requests (or extract from headers)
- Pass the correlation ID to all downstream service calls
- Include the correlation ID in all log entries
- Ensure the ID appears in X-Ray traces

**6. X-Ray Advanced Features**

Enhance X-Ray tracing:
- Add custom annotations for filtering (product ID, request type)
- Add metadata for debugging context
- Trace SNS/SQS message flows

**7. Enhanced Custom Metrics**

Expand business metrics coverage:
- Cache hit/miss rates
- DynamoDB consumed capacity
- Additional dimensions (environment, operation type)

**8. Enhanced Dashboard**

Expand the dashboard to include:
- Latency percentiles (P90, P99)
- Log insights widgets
- Alarm status indicators
- Coverage across all service layers

#### Stretch Goal Deliverables

- `screenshots/Project_Pt_1_Screenshot_5_Correlation_IDs.png`: Take a screenshot of CloudWatch Logs showing the SAME correlation ID appearing in entries from multiple services. Save it as `screenshots/Project_Pt_1_Screenshot_5_Correlation_IDs.png`
- `screenshots/Project_Pt_1_Screenshot_6_XRay_Annotations.png`: Take a screenshot of the X-Ray trace details with "Annotations" tab showing `user_id` and `product_id`. Save it as `screenshots/Project_Pt_1_Screenshot_6_XRay_Annotations.png`
- `screenshots/Project_Pt_1_Screenshot_7_Async_Message_Trace.png`: Take a screenshot of an X-Ray trace spanning SNS publish through to Lambda invocation. Save it as `screenshots/Project_Pt_1_Screenshot_7_Async_Message_Trace.png`
- `screenshots/Project_Pt_1_Screenshot_8_Enhanced_Metrics.png`: Take a screenshot of CloudWatch Metrics showing 4+ metric types with 2+ dimensions. Save it as `screenshots/Project_Pt_1_Screenshot_8_Enhanced_Metrics.png`
- `screenshots/Project_Pt_1_Screenshot_9_Enhanced_Dashboard.png`: Take a screenshot of your enhanced dashboard with widgets covering all layers plus an Alarm Status widget. Save it as `screenshots/Project_Pt_1_Screenshot_9_Enhanced_Dashboard.png`

---

### Part 2: Diagnose and Fix Application Issues

**MVP Time Estimate**: 60-75 minutes | **With Stretch Goals**: 90-120 minutes

#### Situation

With observability in place, you can now see what's happening across the platform. Users are reporting:
- Product pages that sometimes take 10+ seconds to load
- API requests that timeout with 504 errors

- Events that don't trigger expected actions

Your job is to find and fix these issues using the observability tools you implemented.

#### Objectives

Use CloudWatch Logs Insights, X-Ray traces, and metrics to identify and fix production issues.

---

### MVP Requirements (Required)

**1. Analyze Logs with CloudWatch Insights**

**Problem:** There are errors occurring across the platform, but you need to quantify them and identify patterns. Random log browsing is inefficient.

**Task:** Write Logs Insights queries to analyze the log group `/aws/lambda/shopfast-product-service-dev`:
- Find error patterns across services
- Identify the most frequent error types
- Track error frequency over time

**Sample Query Patterns:**
```
# Find all errors
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 50

# Count errors by type
fields @timestamp, @message
| filter @message like /ERROR/
| stats count(*) as error_count by bin(5m)

# Parse structured logs and aggregate
fields @timestamp, level, message
| filter level = "ERROR"
| stats count(*) by message
```

**Verification:** Run the query and observe aggregated/filtered results (not just raw log output).

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of the CloudWatch Logs Insights console showing your query with `filter`, `parse`, or `stats` commands. The results must show aggregated or filtered data, not raw log output. Save it as `screenshots/Project_Pt_2_Screenshot_1_Logs_Insights_Query.png`

---

**2. Debug Lambda Issues**

**Problem:** The product service Lambda (`shopfast-product-service-dev`) is experiencing timeouts and errors. The current timeout is set to 3 seconds and memory to 128MB.

**Task:** Use CloudWatch Logs and X-Ray to:
- Identify Lambda functions with high error rates or timeouts
- Look for `Task timed out after 3.00 seconds` errors
- Find slow downstream dependencies (DynamoDB operations taking too long)

**Where to look:**
- CloudWatch Logs: `/aws/lambda/shopfast-product-service-dev`
- X-Ray: Traces for `shopfast-product-service-dev`
- CloudWatch Metrics: Lambda > By Function Name > Duration, Errors

**Hints:**
- The full table scan in `get_all_products()` can take 4-5 seconds on large tables
- The 3-second timeout causes requests to fail before completion
- Look for patterns: timeouts happen on `/products` endpoint, not `/products/{id}`

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of a CloudWatch Logs entry showing the request ID, timestamp, full stack trace, and error type (e.g., `Task timed out after 3.00 seconds`). Save it as `screenshots/Project_Pt_2_Screenshot_2_Lambda_Error_Debug.png`
- **Screenshot**: Take a screenshot of the X-Ray trace detail view with the timeline expanded, showing segment durations for each operation. Save it as `screenshots/Project_Pt_2_Screenshot_3_XRay_Trace_Analysis.png`
- **Analysis**: Write an analysis explaining the error type, the affected code path, and the root cause of the Lambda errors. Save it as `solution_analyses/Project_Pt_2_Analysis_1_Lambda_Error_Root_Cause.md`
- **Analysis**: Write an analysis identifying the slowest segment in X-Ray traces, its latency, and why it's slow. Save it as `solution_analyses/Project_Pt_2_Analysis_2_XRay_Bottleneck_Identification.md`

---

**3. Document and Verify Fixes**

**Problem:** You need to prove that fixes actually worked and create a knowledge base for future issues.

**Task:** For each issue found, document:
1. **Symptoms** - What was observed (error messages, behavior)
2. **Investigation** - How you found the root cause
3. **Root Cause** - Why it was happening
4. **Fix** - What you changed (include file paths and code changes)
5. **Verification** - Evidence the fix worked (before/after metrics)

Document and fix at least **2 distinct issues** across the platform.

**Expected Issues to Find:**
1. Lambda timeout issue (3s timeout vs 4-5s scan operation)
2. One additional issue from: DynamoDB throttling, EventBridge pattern mismatch, or SQS DLQ messages

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot showing evidence of symptoms observed (error messages, failed requests, etc.). Save it as `screenshots/Project_Pt_2_Screenshot_5_Issue_Documentation.png`
- **Screenshot**: Take a screenshot of a metric or log BEFORE your fix was applied, with timestamp visible. Save it as `screenshots/Project_Pt_2_Screenshot_6_Before_Fix.png`
- **Screenshot**: Take a screenshot of the SAME metric or log AFTER your fix was applied, with a later timestamp visible. Save it as `screenshots/Project_Pt_2_Screenshot_7_After_Fix.png`
- **Analysis**: Write a comprehensive issue documentation file describing at least 3 distinct issues you found. For each issue, include: Symptoms, Investigation, Root Cause, Fix, and Verification. Save it as `solution_analyses/Project_Pt_2_Analysis_4_Issue_Documentation.md`
- **Analysis**: Write a fix verification document with before/after evidence proving your fixes worked. Save it as `solution_analyses/Project_Pt_2_Analysis_5_Fix_Verification.md`

---

#### MVP Deliverables

- `screenshots/Project_Pt_2_Screenshot_1_Logs_Insights_Query.png`: Logs Insights console showing query with `filter`, `parse`, or `stats` - results must show aggregated/filtered data
- `screenshots/Project_Pt_2_Screenshot_2_Lambda_Error_Debug.png`: CloudWatch Logs entry showing request ID, timestamp, full stack trace, and error type
- `screenshots/Project_Pt_2_Screenshot_3_XRay_Trace_Analysis.png`: X-Ray trace detail view with timeline expanded, showing segment durations

- `screenshots/Project_Pt_2_Screenshot_5_Issue_Documentation.png`: Screenshot evidence of symptoms observed
- `screenshots/Project_Pt_2_Screenshot_6_Before_Fix.png`: Metric/log BEFORE fix with timestamp visible
- `screenshots/Project_Pt_2_Screenshot_7_After_Fix.png`: SAME metric/log AFTER fix with later timestamp
- **Analysis Files:**
  - `solution_analyses/Project_Pt_2_Analysis_1_Lambda_Error_Root_Cause.md`
  - `solution_analyses/Project_Pt_2_Analysis_2_XRay_Bottleneck_Identification.md`

  - `solution_analyses/Project_Pt_2_Analysis_4_Issue_Documentation.md` (3+ issues documented)
  - `solution_analyses/Project_Pt_2_Analysis_5_Fix_Verification.md`

---

### Stretch Goals (Optional)

**5. Debug Service Integration Issues**

Investigate the messaging and orchestration layer:
- Investigate SNS/SQS message flow problems and DLQ contents
- Check EventBridge rule configurations for pattern mismatches


**6. Correlate Logs and Traces**

Demonstrate correlation of log entries with X-Ray traces using correlation IDs or request IDs to identify root cause of an issue.

**7. Advanced Lambda Debugging**

Investigate Lambda-specific issues:
- Cold start impact analysis
- Memory and timeout configuration issues
- Provisioned concurrency considerations

#### Stretch Goal Deliverables

- `screenshots/Project_Pt_2_Screenshot_8_EventBridge_Before.png`: Take a screenshot of the EventBridge rule configuration BEFORE your fix
- `screenshots/Project_Pt_2_Screenshot_9_EventBridge_After.png`: Take a screenshot of the EventBridge rule configuration AFTER your fix
- `screenshots/Project_Pt_2_Screenshot_10_DLQ_Inspection.png`: Take a screenshot of the SQS console with a DLQ message body expanded

- `screenshots/Project_Pt_2_Screenshot_12_Log_Entry.png`: Take a screenshot of a CloudWatch log entry with a request/correlation ID visible
- `screenshots/Project_Pt_2_Screenshot_13_XRay_Trace.png`: Take a screenshot of the corresponding X-Ray trace with the same request/correlation ID
- **Analysis Files:**
  - `solution_analyses/Project_Pt_2_Analysis_6_EventBridge_Fix.md`: Document the EventBridge pattern mismatch and your fix
  - `solution_analyses/Project_Pt_2_Analysis_7_DLQ_Failure_Mode.md`: Analyze the failure mode that caused messages to end up in the DLQ

  - `solution_analyses/Project_Pt_2_Analysis_9_Log_Trace_Correlation.md`: Explain how you correlated logs and traces to identify the issue

---

### Part 3: Optimize Performance and Implement Caching

**MVP Time Estimate**: 45-60 minutes | **With Stretch Goals**: 60-90 minutes

#### Situation

With critical issues fixed, the platform is stable but still too slow and expensive. Product pages take 2-3 seconds to load. Lambda functions are misconfigured, causing slow cold starts. The ElastiCache cluster sits idle while every request hits DynamoDB. CloudFront serves API requests without caching.

#### Objectives

Profile, analyze, and optimize the application for better performance.

---

### MVP Requirements (Required)

**1. Profile Application Performance**

**Problem:** You need to identify where time is being spent in request processing to make informed optimization decisions.

**Task:** Use X-Ray and CloudWatch to:
- Identify the slowest operations in request traces for `shopfast-product-service-dev`
- Analyze Lambda duration and memory metrics
- Find at least 2 operations that could benefit from optimization

**Where to look:**
- X-Ray: Traces for `shopfast-product-service-dev` > Click on a trace > View timeline
- CloudWatch: Lambda > By Function Name > `shopfast-product-service-dev` > Duration, Memory

**What to look for:**
- DynamoDB Scan operations (typically 100-500ms)
- Cold start initialization time
- Total request duration vs timeout setting

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of an X-Ray trace timeline showing all segments with durations labeled (identifying the slowest operations). Save it as `screenshots/Project_Pt_3_Screenshot_1_Performance_Profile.png`
- **Screenshot**: Take a screenshot of CloudWatch Lambda metrics showing Duration (average and p99) and MemoryUsed vs MemorySize. Save it as `screenshots/Project_Pt_3_Screenshot_2_Lambda_Metrics.png`
- **Analysis**: Write an analysis identifying at least 2 operations that could benefit from optimization, with specific recommendations. Save it as `solution_analyses/Project_Pt_3_Analysis_1_Performance_Recommendations.md`

---

**2. Right-Size Lambda Resources**

**Problem:** The Lambda function is configured with 128MB memory and 3s timeout, which may not be optimal for the workload.

**Task:** Optimize Lambda resource allocation:
- Analyze Lambda memory usage and cold start times from CloudWatch metrics
- Determine optimal memory settings based on actual usage
- Document before/after metrics showing improvement or cost savings

**How to Deploy Your Changes:**

You can update Lambda configuration using either method:

*Option A - Update directly in Lambda Console:*
1. Navigate to AWS Console > Lambda > Functions > `shopfast-product-service-dev`
2. Go to the **Configuration** tab > **General configuration**
3. Click **Edit**
4. Update **Memory** (e.g., 256MB or 512MB) and **Timeout** (e.g., 10 seconds)
5. Click **Save**

*Option B - Update via AWS CLI in Cloud9:*
```bash
aws lambda update-function-configuration \
  --function-name shopfast-product-service-dev \
  --memory-size 256 \
  --timeout 10
```

**Verification:**

Run the following command in Cloud9 to view the current configuration:

```bash
aws lambda get-function-configuration \
  --function-name shopfast-product-service-dev \
  --query '{Memory: MemorySize, Timeout: Timeout}'
```

After optimization, compare Duration metrics at different memory configurations in CloudWatch.

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of Lambda Duration metrics at the original memory configuration (128MB). Save it as `screenshots/Project_Pt_3_Screenshot_3_Lambda_Before.png`
- **Screenshot**: Take a screenshot of Lambda Duration metrics at the optimized memory configuration. Save it as `screenshots/Project_Pt_3_Screenshot_4_Lambda_After.png`
- **Analysis**: Write an analysis documenting the cost/performance tradeoff of your memory optimization, including before/after metrics. Save it as `solution_analyses/Project_Pt_3_Analysis_2_Cost_Performance_Tradeoff.md`

---

**3. Implement Application Caching**

**Problem:** The ElastiCache Redis cluster (`shopfast-redis-dev`) is deployed but not integrated. Every product request hits DynamoDB directly, adding unnecessary latency and cost.

**Task:** Integrate ElastiCache with the product service:
- Create a cache service module to connect to Redis
- Implement cache-aside pattern for product data
- Set appropriate TTLs (recommended: 300 seconds / 5 minutes)
- Add logging for cache operations (CACHE_HIT, CACHE_MISS, CACHE_SET)

**Files to create/modify:**
- Create a new `cache_service.py` module with Redis client and caching functions
- Modify `starter_code/lambdas/product-service/handler.py` to integrate caching into get_product()

**How to Deploy Your Changes:**

You can deploy your code changes using either method:

*Option A - Edit directly in Lambda Console:*
1. Navigate to AWS Console > Lambda > Functions > `shopfast-product-service-dev`
2. In the Code tab, create a new file `cache_service.py` and add your Redis caching code
3. Edit `handler.py` to import and use the cache service
4. Click **Deploy** to save and deploy your changes

*Option B - Edit in Cloud9 and deploy via CLI:*
1. Create `starter_code/lambdas/product-service/cache_service.py` with your Redis client code
2. Edit `starter_code/lambdas/product-service/handler.py` to integrate caching
3. Zip and deploy with AWS CLI:
   ```bash
   cd starter_code/lambdas/product-service
   zip -r function.zip .
   aws lambda update-function-code \
     --function-name shopfast-product-service-dev \
     --zip-file fileb://function.zip
   ```

**Verification:**

After implementing caching, run the following command in Cloud9 to invoke the Lambda for a specific product:

```bash
aws lambda invoke --function-name shopfast-product-service-dev \
  --payload '{"httpMethod": "GET", "path": "/products/1", "pathParameters": {"id": "1"}}' \
  --cli-binary-format raw-in-base64-out output.json
```

Run the same command again - the second request should show CACHE_HIT in logs:

```bash
aws lambda invoke --function-name shopfast-product-service-dev \
  --payload '{"httpMethod": "GET", "path": "/products/1", "pathParameters": {"id": "1"}}' \
  --cli-binary-format raw-in-base64-out output.json
```

Then check logs for cache operations:

```bash
aws logs filter-log-events \
  --log-group-name /aws/lambda/shopfast-product-service-dev \
  --filter-pattern "CACHE" \
  --limit 10
```

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of CloudWatch Logs showing `CACHE_HIT`, `CACHE_MISS`, and `CACHE_SET` log entries with keys and TTL values visible. Save it as `screenshots/Project_Pt_3_Screenshot_5_Redis_Cache_Logs.png`
- **Screenshot**: Take a screenshot demonstrating cache usage (e.g., multiple CACHE_HIT entries for the same key, or a cache hit count metric > 0). Save it as `screenshots/Project_Pt_3_Screenshot_6_Cache_Verification.png`
- **Code**: Your `cache_service.py` module showing Redis client initialization with `shopfast-redis-dev` endpoint
- **Analysis**: Write an analysis justifying your choice of cache TTL values (why 300 seconds or your chosen value is appropriate for product data). Save it as `solution_analyses/Project_Pt_3_Analysis_3_Cache_TTL_Justification.md`

---

#### MVP Deliverables

- `screenshots/Project_Pt_3_Screenshot_1_Performance_Profile.png`: X-Ray trace timeline with all segments visible and durations labeled
- `screenshots/Project_Pt_3_Screenshot_2_Lambda_Metrics.png`: CloudWatch metrics showing Duration (average and p99) and MemoryUsed vs MemorySize
- `screenshots/Project_Pt_3_Screenshot_3_Lambda_Before.png`: Lambda Duration metrics at original memory configuration
- `screenshots/Project_Pt_3_Screenshot_4_Lambda_After.png`: Lambda Duration metrics at optimized memory configuration
- `screenshots/Project_Pt_3_Screenshot_5_Redis_Cache_Logs.png`: CloudWatch Logs showing `CACHE_HIT`, `CACHE_MISS`, `CACHE_SET` with keys and TTL values
- `screenshots/Project_Pt_3_Screenshot_6_Cache_Verification.png`: Cache hit count > 0 demonstrating cache usage
- **Code:** Your `cache_service.py` showing Redis client initialization with `shopfast-redis-dev` endpoint
- **Analysis Files:**
  - `solution_analyses/Project_Pt_3_Analysis_1_Performance_Recommendations.md`
  - `solution_analyses/Project_Pt_3_Analysis_2_Cost_Performance_Tradeoff.md`
  - `solution_analyses/Project_Pt_3_Analysis_3_Cache_TTL_Justification.md`

---

### Stretch Goals (Optional)

**4. Profile Database Query Performance**

Analyze database performance:
- DynamoDB consumed capacity analysis
- Identify throttling events
- Identify specific slow query patterns

**5. Configure Edge Caching**

Optimize CloudFront for static assets:
- Configure cache behaviors for different content types (HTML, JS, CSS, images)
- Set appropriate TTLs for different content types
- Monitor cache hit rates for static content

**6. Optimize Message Routing**

Add SNS filter policies to:
- Route messages only to relevant subscribers
- Reduce unnecessary message processing
- Filter by message attributes

#### Stretch Goal Deliverables

- `screenshots/Project_Pt_3_Screenshot_8_DynamoDB_Metrics.png`: Take a screenshot of CloudWatch metrics showing ConsumedReadCapacityUnits and ConsumedWriteCapacityUnits
- `screenshots/Project_Pt_3_Screenshot_9_SNS_Filter_Policy.png`: Take a screenshot of the SNS console showing your filter policy JSON
- `screenshots/Project_Pt_3_Screenshot_10_CloudFront_Behaviors.png`: Take a screenshot of CloudFront cache behaviors with path patterns and TTL settings
- `screenshots/Project_Pt_3_Screenshot_11_CloudFront_TTLs.png`: Take a screenshot of CloudFront TTL configuration for different content types
- `screenshots/Project_Pt_3_Screenshot_12_Cache_Hit_Rate.png`: Take a screenshot of CloudFront statistics showing cache hit rate percentage
- **Analysis File:** `solution_analyses/Project_Pt_3_Analysis_4_DynamoDB_Patterns.md`: Document DynamoDB query patterns and optimization opportunities

---

### Part 4: Configure Monitoring, Alerts, and Health Checks

**MVP Time Estimate**: 30-45 minutes | **With Stretch Goals**: 45-60 minutes

#### Situation

The platform is now stable, fast, and cost-optimized. But you need to ensure it stays that way. Currently, there are no health checks, no alarms to catch problems early, and no way to track whether the platform is meeting its service level objectives.

#### Objectives

Implement production-grade monitoring to maintain platform health.

---

### MVP Requirements (Required)

**1. Implement Basic Health Endpoints**

**Problem:** There's no way to programmatically check if the service and its dependencies are healthy. Load balancers and monitoring systems need a health endpoint.

**Task:** Add a health check handler that:
- Returns meaningful health status (not just 200 OK)
- Checks at least one dependency (DynamoDB table `shopfast-products-dev`)
- Optionally checks Redis connectivity (`shopfast-redis-dev`)

**File to create:**
- `health_handler.py` - Health check endpoint handler

**How to Deploy Your Changes:**

You can deploy your code changes using either method:

*Option A - Edit directly in Lambda Console:*
1. Navigate to AWS Console > Lambda > Functions > `shopfast-product-service-dev`
2. In the Code tab, create a new file `health_handler.py` and add your health check code
3. Edit `handler.py` to route `/health` requests to your health handler
4. Click **Deploy** to save and deploy your changes

*Option B - Edit in Cloud9 and deploy via CLI:*
1. Create `starter_code/lambdas/product-service/health_handler.py` with your health check code
2. Edit `starter_code/lambdas/product-service/handler.py` to route `/health` requests
3. Zip and deploy with AWS CLI:
   ```bash
   cd starter_code/lambdas/product-service
   zip -r function.zip .
   aws lambda update-function-code \
     --function-name shopfast-product-service-dev \
     --zip-file fileb://function.zip
   ```

**Expected Response Format:**
```json
{
  "status": "healthy",
  "dependencies": {
    "dynamodb": "connected",
    "redis": "connected"
  },
  "timestamp": "2024-01-15T12:00:00.000Z"
}
```

**Verification:**

Run the following commands in Cloud9 to test the health endpoint:

```bash
aws lambda invoke --function-name shopfast-product-service-dev \
  --payload '{"httpMethod": "GET", "path": "/health"}' \
  --cli-binary-format raw-in-base64-out output.json
```

Then view the response:

```bash
cat output.json
```

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of the Lambda invoke output (or CloudWatch Logs) showing the health endpoint JSON response with `status`, `dependencies`, and `timestamp` fields. Save it as `screenshots/Project_Pt_4_Screenshot_1_Health_Endpoint.png`
- **Code**: Your `health_handler.py` module showing DynamoDB and optionally Redis connectivity checks

---

**2. Create Essential CloudWatch Alarms**

**Problem:** There's no automated alerting when things go wrong. Issues are only discovered when users complain.

**Task:** Create alarms for critical metrics (at least 3):
1. `ShopFast-dev-ProductService-Errors`: Lambda error rate threshold
2. `ShopFast-dev-ProductService-Duration`: Lambda duration/timeout threshold
3. `ShopFast-dev-DynamoDB-Throttling`: DynamoDB throttling events

**Verification:**

Run the following command in Cloud9 to list the alarms:

```bash
aws cloudwatch describe-alarms \
  --alarm-name-prefix "ShopFast-dev" \
  --query 'MetricAlarms[].{Name:AlarmName,State:StateValue,Threshold:Threshold}'
```

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of the CloudWatch Alarms console showing all three alarms: `ShopFast-dev-ProductService-Errors`, `ShopFast-dev-ProductService-Duration`, and `ShopFast-dev-DynamoDB-Throttling`. Save it as `screenshots/Project_Pt_4_Screenshot_2_CloudWatch_Alarms.png`
- **Screenshot**: Take a screenshot of an alarm configuration detail page showing thresholds and evaluation periods. Save it as `screenshots/Project_Pt_4_Screenshot_3_Alarm_Thresholds.png`
- **Analysis**: Write an analysis justifying your choice of alarm thresholds (why these specific values were chosen based on baseline metrics). Save it as `solution_analyses/Project_Pt_4_Analysis_1_Alarm_Threshold_Justification.md`

---

**3. Set Up Basic Notifications**

**Problem:** Even with alarms, there's no way to receive notifications when they trigger.

**Task:** Configure SNS for alerting:
- Use or create the SNS topic `shopfast-notifications-dev`
- Subscribe an email endpoint
- Connect alarms to the notification topic
- Test alert delivery

**Verification:**

Run the following command in Cloud9 to list SNS subscriptions (replace `ACCOUNT_ID` with your AWS account ID):

```bash
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:us-east-1:ACCOUNT_ID:shopfast-notifications-dev
```

To test notification delivery, set the alarm state to ALARM:

```bash
aws cloudwatch set-alarm-state \
  --alarm-name "ShopFast-dev-ProductService-Errors" \
  --state-value ALARM \
  --state-reason "Testing notification delivery"
```

Check your email for the alarm notification.

**Submitting Your Answer:**
- **Screenshot**: Take a screenshot of the SNS topic console showing your email subscription with "Confirmed" status. Save it as `screenshots/Project_Pt_4_Screenshot_4_SNS_Subscription.png`
- **Screenshot**: Take a screenshot of an actual email you received showing the alarm name, state change, and timestamp. Save it as `screenshots/Project_Pt_4_Screenshot_5_Notification_Email.png`

---

#### MVP Deliverables

- `screenshots/Project_Pt_4_Screenshot_1_Health_Endpoint.png`: Lambda invoke output showing JSON: `{"status": "healthy", "dependencies": {"dynamodb": "connected", "redis": "connected"}}`
- `screenshots/Project_Pt_4_Screenshot_2_CloudWatch_Alarms.png`: All three alarms: `ShopFast-dev-ProductService-Errors`, `ShopFast-dev-ProductService-Duration`, `ShopFast-dev-DynamoDB-Throttling`
- `screenshots/Project_Pt_4_Screenshot_3_Alarm_Thresholds.png`: Alarm configuration details showing thresholds with evaluation periods
- `screenshots/Project_Pt_4_Screenshot_4_SNS_Subscription.png`: SNS topic showing email subscription with "Confirmed" status
- `screenshots/Project_Pt_4_Screenshot_5_Notification_Email.png`: Actual email received showing alarm name, state change, and timestamp
- **Code:** Your `health_handler.py` showing connectivity checks
- **Analysis File:** `solution_analyses/Project_Pt_4_Analysis_1_Alarm_Threshold_Justification.md`

---

### Stretch Goals (Optional)

**4. Advanced Alerting**

Implement sophisticated alerting:
- Create composite alarms for service-level health
- Implement tiered alerting (warning vs critical levels)
- Create EventBridge rules for Lambda error events

**5. Build SLI/SLO Dashboard**

Create a dashboard tracking:
- Availability (successful requests / total requests)
- Latency (P99 < target)
- Error rate (errors / total requests)
- Service level indicators with defined targets

**6. Resource Utilization Analysis**

Analyze and document:
- Current resource utilization patterns across services
- Recommendations for capacity planning
- Cost optimization opportunities

#### Stretch Goal Deliverables

- `screenshots/Project_Pt_4_Screenshot_6_EventBridge_Rule.png`: Take a screenshot of an EventBridge rule on `shopfast-events-dev` bus with event pattern and target visible
- `screenshots/Project_Pt_4_Screenshot_7_SLI_SLO_Dashboard.png`: Take a screenshot of your SLI/SLO dashboard with availability, latency p99, and error rate with target lines
- `screenshots/Project_Pt_4_Screenshot_8_Composite_Alarms.png`: Take a screenshot of a composite alarm or tiered alerting configuration
- `screenshots/Project_Pt_4_Screenshot_9_Resource_Utilization.png`: Take a screenshot showing Lambda concurrent executions and DynamoDB consumed vs provisioned capacity
- **Analysis Files:**
  - `solution_analyses/Project_Pt_4_Analysis_2_Composite_Alarm_Design.md`: Document your composite alarm design and why it reduces alert fatigue
  - `solution_analyses/Project_Pt_4_Analysis_3_Capacity_Planning.md`: Analyze resource utilization patterns and provide capacity planning recommendations

---

## Helpful Hints

### General Tips

- **Start with exploration**: Before making changes, use the AWS Console to explore the current state of each service
- **Work incrementally**: Implement one change at a time and verify it works before moving on
- **Document as you go**: Take screenshots and notes as you complete each task
- **Use the course materials**: Reference specific lessons for techniques and code examples
- **Check the logs**: CloudWatch Logs is your best friend for debugging
- **Focus on MVP first**: Complete all required tasks before attempting stretch goals

### Part-Specific Hints

**Part 1: Observability**
- AWS Lambda Powertools simplifies structured logging and X-Ray integration
- EMF metrics can be emitted directly from Lambda without API calls
- Remember to enable X-Ray on both the Lambda function AND API Gateway

**Part 2: Debugging**
- Always check the Dead Letter Queue (DLQ) for failed messages

- X-Ray annotations make traces searchable by business identifiers
- Look for DynamoDB throttling (ProvisionedThroughputExceededException)

**Part 3: Optimization**
- Start with the biggest impact optimizations (usually caching)
- Lambda memory directly affects CPU allocation
- CloudFront cache hit ratio should be >80% for static content
- Filter policies on SNS can dramatically reduce unnecessary processing

**Part 4: Monitoring**
- Health checks should verify dependencies, not just return 200
- Composite alarms reduce alert fatigue
- Start with conservative alarm thresholds and adjust based on baselines
- SLOs should be based on customer experience, not arbitrary numbers

---

## Submission Checklist

Before submitting your project, verify you have completed the required items. All screenshots should be in the `screenshots/` folder and all analysis files should be in the `solution_analyses/` folder.

### Part 1: Observability (Required)

**Screenshots (in `screenshots/` folder):**
- `Project_Pt_1_Screenshot_1_Structured_JSON_Logging.png`
- `Project_Pt_1_Screenshot_2_XRay_Service_Map.png`
- `Project_Pt_1_Screenshot_3_Custom_EMF_Metrics.png`
- `Project_Pt_1_Screenshot_4_Operational_Dashboard.png`

**Code:**
- Your modified `handler.py` showing Logger, X-Ray, and EMF implementations

### Part 2: Debugging (Required)

**Screenshots (in `screenshots/` folder):**
- `Project_Pt_2_Screenshot_1_Logs_Insights_Query.png`
- `Project_Pt_2_Screenshot_2_Lambda_Error_Debug.png`
- `Project_Pt_2_Screenshot_3_XRay_Trace_Analysis.png`

- `Project_Pt_2_Screenshot_5_Issue_Documentation.png`
- `Project_Pt_2_Screenshot_6_Before_Fix.png`
- `Project_Pt_2_Screenshot_7_After_Fix.png`

**Analysis Files (in `solution_analyses/` folder):**
- `Project_Pt_2_Analysis_1_Lambda_Error_Root_Cause.md`
- `Project_Pt_2_Analysis_2_XRay_Bottleneck_Identification.md`

- `Project_Pt_2_Analysis_4_Issue_Documentation.md`
- `Project_Pt_2_Analysis_5_Fix_Verification.md`

### Part 3: Optimization (Required)

**Screenshots (in `screenshots/` folder):**
- `Project_Pt_3_Screenshot_1_Performance_Profile.png`
- `Project_Pt_3_Screenshot_2_Lambda_Metrics.png`
- `Project_Pt_3_Screenshot_3_Lambda_Before.png`
- `Project_Pt_3_Screenshot_4_Lambda_After.png`
- `Project_Pt_3_Screenshot_5_Redis_Cache_Logs.png`
- `Project_Pt_3_Screenshot_6_Cache_Verification.png`

**Code:**
- Your `cache_service.py` showing Redis integration

**Analysis Files (in `solution_analyses/` folder):**
- `Project_Pt_3_Analysis_1_Performance_Recommendations.md`
- `Project_Pt_3_Analysis_2_Cost_Performance_Tradeoff.md`
- `Project_Pt_3_Analysis_3_Cache_TTL_Justification.md`

### Part 4: Monitoring (Required)

**Screenshots (in `screenshots/` folder):**
- `Project_Pt_4_Screenshot_1_Health_Endpoint.png`
- `Project_Pt_4_Screenshot_2_CloudWatch_Alarms.png`
- `Project_Pt_4_Screenshot_3_Alarm_Thresholds.png`
- `Project_Pt_4_Screenshot_4_SNS_Subscription.png`
- `Project_Pt_4_Screenshot_5_Notification_Email.png`

**Code:**
- Your `health_handler.py` showing health check implementation

**Analysis Files (in `solution_analyses/` folder):**
- `Project_Pt_4_Analysis_1_Alarm_Threshold_Justification.md`

---

### Stretch Goals (Optional)

#### Part 1: Observability (Screenshots in `screenshots/` folder)
- `Project_Pt_1_Screenshot_5_Correlation_IDs.png`
- `Project_Pt_1_Screenshot_6_XRay_Annotations.png`
- `Project_Pt_1_Screenshot_7_Async_Message_Trace.png`
- `Project_Pt_1_Screenshot_8_Enhanced_Metrics.png`
- `Project_Pt_1_Screenshot_9_Enhanced_Dashboard.png`

#### Part 2: Debugging (Screenshots in `screenshots/` folder, analysis in `solution_analyses/` folder)
- `Project_Pt_2_Screenshot_8_EventBridge_Before.png`
- `Project_Pt_2_Screenshot_9_EventBridge_After.png`
- `Project_Pt_2_Screenshot_10_DLQ_Inspection.png`

- `Project_Pt_2_Screenshot_12_Log_Entry.png`
- `Project_Pt_2_Screenshot_13_XRay_Trace.png`
- `Project_Pt_2_Analysis_6_EventBridge_Fix.md`
- `Project_Pt_2_Analysis_7_DLQ_Failure_Mode.md`

- `Project_Pt_2_Analysis_9_Log_Trace_Correlation.md`

#### Part 3: Optimization (Screenshots in `screenshots/` folder, analysis in `solution_analyses/` folder)
- `Project_Pt_3_Screenshot_8_DynamoDB_Metrics.png`
- `Project_Pt_3_Screenshot_9_SNS_Filter_Policy.png`
- `Project_Pt_3_Screenshot_10_CloudFront_Behaviors.png`
- `Project_Pt_3_Screenshot_11_CloudFront_TTLs.png`
- `Project_Pt_3_Screenshot_12_Cache_Hit_Rate.png`
- `Project_Pt_3_Analysis_4_DynamoDB_Patterns.md`

#### Part 4: Monitoring (Screenshots in `screenshots/` folder, analysis in `solution_analyses/` folder)
- `Project_Pt_4_Screenshot_6_EventBridge_Rule.png`
- `Project_Pt_4_Screenshot_7_SLI_SLO_Dashboard.png`
- `Project_Pt_4_Screenshot_8_Composite_Alarms.png`
- `Project_Pt_4_Screenshot_9_Resource_Utilization.png`
- `Project_Pt_4_Analysis_2_Composite_Alarm_Design.md`
- `Project_Pt_4_Analysis_3_Capacity_Planning.md`

---

## Time Summary

| Part | MVP (Required) | With Stretch Goals |
|------|----------------|-------------------|
| Part 1: Observability | 60-75 min | 90-120 min |
| Part 2: Debugging | 60-75 min | 90-120 min |
| Part 3: Optimization | 45-60 min | 60-90 min |
| Part 4: Monitoring | 30-45 min | 45-60 min |
| **Total** | **3-4 hours** | **4-6 hours** |

---

## Evaluation

Your work will be assessed using the rubric provided on the following page. Review the rubric before starting, consult it as you work, and verify all requirements are met before submission.

**Grading**: This project is graded on a **pass/fail** basis.

- **To Pass**: All MVP rubric items must be satisfied
- **Stretch Goals**: Completing stretch goals demonstrates advanced competency but is not required to pass

**Note**: Stretch goal completion will be noted in feedback and may be considered for distinctions or recommendations.
