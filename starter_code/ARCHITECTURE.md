# ShopFast Architecture

## System Overview

ShopFast is a cloud-native e-commerce platform built on AWS using a fully serverless architecture. All compute is handled by AWS Lambda, with DynamoDB for data storage and various AWS services for messaging and orchestration.

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
         │                        │                         │
         ▼                        ▼                         ▼
┌─────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  Lambda         │    │  Lambda             │    │  Lambda             │
│  product-service│    │  order-service      │    │  inventory-service  │
│  (Python 3.11)  │    │  (Python 3.11)      │    │  (Python 3.11)      │
└────────┬────────┘    └──────────┬──────────┘    └──────────┬──────────┘
         │                        │                          │
         ▼                        ▼                          ▼
┌─────────────────┐    ┌─────────────────────┐    ┌─────────────────────┐
│  DynamoDB       │    │  DynamoDB           │    │  DynamoDB           │
│  (Products)     │    │  (Orders)           │    │  (Inventory)        │
└─────────────────┘    └─────────────────────┘    └─────────────────────┘
                                │
                                ▼
                  ┌─────────────────────────┐
                  │      EventBridge        │
                  │   (Order Events Bus)    │
                  └────────────┬────────────┘
                               │
          ┌────────────────────┼────────────────────┐
          ┌──────────────────────┼────────────────────┐
          ▼                      ▼                    ▼
┌─────────────────┐  ┌─────────────────────┐
│  SNS Topic      │  │  Lambda             │
│  (Notifications)│  │  notification-      │
│                 │  │  handler            │
└─────────────────┘  └─────────────────────┘
                               │
                               ▼
                     ┌─────────────────┐
                     │  SQS Queue      │
                     │  (Dead Letter)  │
                     └─────────────────┘
```

## Service Details

### Frontend (React)

| Attribute | Value |
|-----------|-------|
| Runtime | React 19 |
| Hosting | S3 + CloudFront |
| Build Tool | Vite |
| Package Manager | npm |

**Responsibilities:**
- Product browsing and search
- Shopping cart management
- Checkout flow
- Order status tracking

### Product Service (Lambda)

| Attribute | Value |
|-----------|-------|
| Runtime | Python 3.11 |
| Trigger | Lambda Function URL |
| Data Store | DynamoDB (products table) |
| Timeout | 3 seconds |
| Memory | 128 MB |

**Endpoints:**
- `GET /products` - List all products
- `GET /products/{id}` - Get product details

### Order Service (Lambda)

| Attribute | Value |
|-----------|-------|
| Runtime | Python 3.11 |
| Trigger | API Gateway |
| Data Store | DynamoDB (orders table) |
| Timeout | 30 seconds |
| Memory | 512 MB |

**Endpoints:**
- `POST /orders` - Create new order
- `GET /orders/{id}` - Get order details
- `GET /orders` - List user orders

**Flow:**
- Validates order data
- Calls Inventory Service to reserve stock
- Stores order in DynamoDB
- Publishes event to EventBridge

### Inventory Service (Lambda)

| Attribute | Value |
|-----------|-------|
| Runtime | Python 3.11 |
| Trigger | API Gateway |
| Data Store | DynamoDB (inventory table) |
| Timeout | 30 seconds |
| Memory | 512 MB |

**Endpoints:**
- `GET /inventory/{productId}` - Check stock level
- `PUT /inventory/{productId}` - Update stock level
- `POST /inventory/reserve` - Reserve inventory for order

### Notification Handler (Lambda)

| Attribute | Value |
|-----------|-------|
| Runtime | Python 3.11 |
| Trigger | SNS Topic |
| Purpose | Process order notifications |

**Responsibilities:**
- Send order confirmation emails
- Send shipping notifications
- Handle notification failures

## Data Flow

### Order Placement Flow

1. **User submits order** via React frontend
2. **API Gateway** routes to order-service Lambda
3. **Order Service Lambda**:
   - Validates order data
   - Calls Inventory Service Lambda to reserve stock
   - Stores order in DynamoDB
   - Publishes event to EventBridge
4. **EventBridge** routes event to:
   - SNS Topic (notifications)
5. **Notification Handler Lambda**:
   - Receives SNS message
   - Sends customer notifications

### Product Browsing Flow

1. **User requests products** via React frontend
2. **API Gateway** routes to product-service Lambda
3. **Product Service** scans DynamoDB products table
4. **Response** returned through API Gateway to frontend

## Integration Points

### EventBridge

**Event Bus:** `shopfast-events`

**Event Pattern:**
```json
{
  "source": ["shopfast.order-service"],
  "detail-type": ["order.created", "order.updated", "order.shipped"]
}
```

### SNS Topics

| Topic | Purpose | Subscribers |
|-------|---------|-------------|
| `shopfast-order-events` | Order lifecycle events | notification-handler Lambda |
| `shopfast-inventory-updates` | Stock level changes | Analytics pipeline |
| `shopfast-notifications` | Customer notifications | Email/SMS services |

### SQS Queues

| Queue | Purpose |
|-------|---------|
| `shopfast-order-queue` | Order processing buffer |
| `shopfast-notification-dlq` | Failed notification retry |
| `shopfast-inventory-dlq` | Failed inventory update retry |

## Security

### Network

- VPC with public and private subnets
- NAT Gateway for outbound internet from private subnets
- Security groups for Lambda VPC access

### IAM

- Lambda execution roles with least-privilege policies
- DynamoDB access via IAM roles
- SNS/SQS/EventBridge access via IAM roles

### Data

- DynamoDB encryption at rest
- HTTPS for all API endpoints
- Secrets stored in AWS Secrets Manager

## Observability (To Be Added)

The starter code does **not** include observability instrumentation. You will add:

- **AWS X-Ray** - Distributed tracing for Lambda functions
- **CloudWatch Logs** - Structured JSON logging
- **CloudWatch Metrics** - EMF custom metrics
- **CloudWatch Alarms** - Proactive alerting for Lambda and DynamoDB
- **Correlation IDs** - Request tracing across services

## Resource Naming Convention

All resources follow the pattern: `shopfast-{service}-{resource}`

Examples:
- `shopfast-products` (DynamoDB table)
- `shopfast-product-service` (Lambda function)
- `shopfast-order-service` (Lambda function)
- `shopfast-events` (EventBridge bus)
