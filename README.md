# ShopFast E-Commerce Platform: Troubleshooting & Optimization Project

## Overview

It's 2 AM and your phone is buzzing with alerts. **ShopFast**, a rapidly growing e-commerce startup, is experiencing their worst nightmare during Black Friday weekend.

ShopFast has grown from a small online retailer to processing over 50,000 orders daily. Their engineering team worked around the clock to scale their AWS infrastructure for the holiday rush, but the hastily assembled system is now falling apart. Customers are reporting slow page loads, failed checkouts, and missing order confirmations.

As a **Senior DevOps Consultant**, the CTO has brought you in to save their platform. You'll implement proper observability, identify and fix issues plaguing the platform, optimize performance, and build production-grade monitoring.

### Learning Objectives

- **Implement Observability**: Transform a poorly instrumented application into a fully observable system
- **Debug Under Pressure**: Use logs, metrics, and traces to identify root causes of production issues
- **Optimize for Performance**: Profile bottlenecks and implement caching strategies
- **Build for Production**: Create monitoring and alerting that catches problems before customers do

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CloudFront CDN                                  │
│                           (Frontend Distribution)                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                               S3 Bucket                                      │
│                          (React Static Assets)                               │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          Lambda Function URLs                                │
│                       (Direct HTTP API Endpoints)                            │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────┐
                    │  Lambda: product-service        │
                    │  (Python 3.11)                  │
                    └────────────────┬────────────────┘
                                     │
              ┌──────────────────────┼──────────────────────┐
              ▼                      ▼                      ▼
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│  DynamoDB           │  │  ElastiCache Redis  │  │  SNS Topic          │
│  (Products Table)   │  │  (Caching Layer)    │  │  (Product Events)   │
└─────────────────────┘  └─────────────────────┘  └──────────┬──────────┘
                                                             │
                         ┌───────────────────────────────────┤
                         ▼                                   ▼
           ┌─────────────────────────┐         ┌─────────────────────────┐
           │  EventBridge            │         │  Lambda:                │
           │  (shopfast-events)      │         │  notification-handler   │
           └────────────┬────────────┘         └─────────────────────────┘
                        │
                        ▼
           ┌─────────────────────────┐
           │  SQS Queue              │
           │  (+ Dead Letter Queue)  │
           └─────────────────────────┘
```

### Service Summary

| Service | Platform | Runtime | Data Store |
|---------|----------|---------|------------|
| Frontend | CloudFront + S3 | React 18 | - |
| Product Service | Lambda (Function URL) | Python 3.11 | DynamoDB |
| Notification Handler | Lambda | Python 3.11 | - |

### Integration Layer

- **EventBridge**: Product events bus (`shopfast-events`)
- **SNS Topics**: Product events, customer notifications
- **SQS Queues**: Product processing queue, dead letter queue

---

## Getting Started

### Cloud9 Setup

1. Open the AWS Console and navigate to **Cloud9**
2. Click **Create environment**
3. Configure:
   - Name: `shopfast-dev`
   - Set your instance type to: `t3.medium`:
     - Go to `New EC2 Instance`
     - Click `Additional instance types`
     - Click the Drop Down under `Additional Instance Types`
     - Search for `t3.medium`
     - Select `t3.medium`
   - Platform: Amazon Linux 2023
4. Click **Create**
5. Wait for the environment to initialize

### Open the Cloud9 IDE
1.  Now that you have created the environment, you can access Cloud9 from the Cloud9 service in the AWS Console.
2.  Select the environment you just created and click **Open in Cloud9**
3.  You should now be in the Cloud9 IDE, here's is a quick overview of what Cloud9 is:
    -  The Cloud9 IDE is an AWS cloud-based integrated development environment (IDE) that lets you write, run, and debug code in your browser.
    - Think of it as VS Code but running in your AWS cloud environment.
    - You can use the Cloud9 IDE to write, run, and debug your code, and to interact with AWS services.
    - We will be using the Cloud9 IDE to both bootstrap our environment and to complete the project.

### Cloning the Repository
1. Once the Cloud9 IDE is open, you can use the terminal at the bottom of the IDE to clone the repository.
2. Click inside the bash terminal (lower right corner of the console) and paste the following commands:
  - `git clone https://github.com/udacity/cd14940-troubleshooting-and-optimization-in-aws-for-developers.git`
  - `cd cd14940-troubleshooting-and-optimization-in-aws-for-developers/starter/bootstrap_scripts`

### Installing Dependencies
- To install the dependencies run the following commands:
  - `chmod +x scripts/setup-environment.sh`
  - `bash scripts/setup-environment.sh`
- **Note:** The script takes about 5 minutes to run.
- This script will install:
  - AWS SAM CLI
  - Docker
  - uv (Python package manager)
  - Node.js 18+

### Bootstrap Infrastructure
- Run the following commands to bootstrap the environment:
  - `chmod +x bootstrap.sh`
  - `bash bootstrap.sh`

The bootstrap process takes approximately 20-30 minutes and will:
1. Create networking infrastructure (VPC, subnets, security groups)
2. Deploy data stores (DynamoDB, ElastiCache)
3. Set up messaging (SNS, SQS, EventBridge)
4. Deploy compute resources (Lambda with Function URLs)
5. Configure CloudFront
6. Deploy the React frontend
7. Seed sample data

5. **Verify Deployment**
   ```bash
   ./verify-deployment.sh
   ```

### Environment Variables

After bootstrapping, the following variables are configured:

| Variable | Description |
|----------|-------------|
| `API_ENDPOINT` | Lambda Function URL for product service |
| `CLOUDFRONT_URL` | Frontend distribution URL |

---

## Project Instructions

This project is organized into four parts:

| Part | Description | MVP Time |
|------|-------------|----------|
| **Part 1** | Implement Comprehensive Observability | 60-75 min |
| **Part 2** | Diagnose and Fix Application Issues | 60-75 min |
| **Part 3** | Optimize Performance and Implement Caching | 45-60 min |
| **Part 4** | Configure Monitoring, Alerts, and Health Checks | 30-45 min |
| **Total** | All MVP Requirements | 3-4 hours |

### Part 1: Implement Observability

- Implement structured JSON logging
- Enable X-Ray tracing on Lambda
- Publish custom EMF metrics
- Build operational CloudWatch dashboard

### Part 2: Diagnose and Fix Issues

- Analyze logs with CloudWatch Insights
- Debug Lambda service issues
- Document and verify fixes for at least 3 distinct issues

### Part 3: Optimize Performance

- Profile application performance with X-Ray
- Right-size Lambda resources
- Integrate ElastiCache Redis for caching

### Part 4: Configure Monitoring

- Implement health check endpoints
- Create CloudWatch alarms
- Set up SNS notifications

**For complete instructions, see [Project_Instructions.md](documentation/Project_Instructions.md)**

---

## Directory Structure

```
starter/
├── bootstrap_scripts/      # Infrastructure deployment scripts
│   ├── bootstrap.sh        # Main deployment script
│   ├── cleanup.sh          # Resource cleanup
│   └── verify-deployment.sh
├── starter_code/           # Application code to troubleshoot
├── documentation/          # Instructions and rubric
├── README.md               # This file
└── Project_Rubric.md       # Grading criteria
```

---

## Testing & Verification

### Verify Infrastructure

```bash
# Check all services are running
./bootstrap_scripts/verify-deployment.sh

# Verify Lambda Function URL
curl -X GET ${API_ENDPOINT}products

# Verify CloudFront
curl -I $CLOUDFRONT_URL
```

### Health Check Endpoints

| Service | Endpoint |
|---------|----------|
| Product Service | `GET /health` (via Lambda Function URL) |

---

## Cleanup

When finished with the project, clean up all AWS resources:

```bash
cd bootstrap_scripts
./cleanup.sh
```

**Warning**: This will permanently delete all deployed resources and data. Ensure you have saved all required screenshots and documentation before running cleanup.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Bootstrap fails | Check IAM permissions; ensure Cloud9 has Admin role |
| Lambda timeout | Check VPC configuration and security groups |
| DynamoDB throttling | Verify provisioned capacity or enable on-demand |
| Redis connection failed | Verify security groups allow port 6379 |

### Getting Help

1. Review CloudWatch Logs for error messages
2. Check X-Ray service map for failed traces
3. Verify IAM permissions for each service
4. Consult course materials for specific techniques

---

## Built With

### AWS Services

- **Compute**: Lambda (with Function URLs)
- **Storage**: S3, DynamoDB
- **Caching**: ElastiCache Redis
- **Networking**: CloudFront, VPC
- **Messaging**: SNS, SQS, EventBridge
- **Observability**: CloudWatch, X-Ray

### Technologies

- React 18 (Frontend)
- Python 3.11 (Backend Services)
- AWS SAM / CloudFormation (Infrastructure)

---

## License

[License](../LICENSE.txt)
