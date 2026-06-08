#!/bin/bash
#
# Deploy Lambda Functions using AWS SAM
#

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
STARTER_CODE="${PROJECT_ROOT}/../starter_code"
AWS_REGION="${AWS_REGION:-us-east-1}"
STACK_PREFIX="shopfast"
ENVIRONMENT="${ENVIRONMENT:-dev}"

# Create S3 bucket for SAM artifacts (uses shopfast- prefix to match IAM policy)
SAM_BUCKET="shopfast-sam-artifacts-$(aws sts get-caller-identity --query Account --output text)"
if ! aws s3 ls "s3://${SAM_BUCKET}" 2>/dev/null; then
    echo -e "${YELLOW}Creating S3 bucket for SAM artifacts: ${SAM_BUCKET}${NC}"
    aws s3 mb "s3://${SAM_BUCKET}" --region "${AWS_REGION}"
fi

echo -e "${GREEN}Deploying Lambda Functions${NC}"
echo ""

# Check if starter code exists
if [ ! -d "${STARTER_CODE}/lambdas" ]; then
    echo -e "${YELLOW}Starter code not found, using placeholder functions${NC}"

    # Create temporary Lambda deployment package
    TEMP_DIR=$(mktemp -d)

    # Product Service Lambda (with planted issue: short timeout)
    cat > "${TEMP_DIR}/product_handler.py" << 'EOF'
import json
import boto3
import time

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('shopfast-products-dev')

def handler(event, context):
    """Product service handler - basic print statements, no structured logging"""
    print("Received event:", json.dumps(event))

    http_method = event.get('httpMethod', 'GET')
    path_params = event.get('pathParameters') or {}

    if http_method == 'GET':
        if 'productId' in path_params:
            return get_product(path_params['productId'])
        else:
            return list_products()

    return {
        'statusCode': 405,
        'body': json.dumps({'error': 'Method not allowed'})
    }

def get_product(product_id):
    print(f"Getting product: {product_id}")
    try:
        response = table.get_item(Key={'productId': product_id})
        if 'Item' in response:
            return {
                'statusCode': 200,
                'headers': {'Content-Type': 'application/json'},
                'body': json.dumps(response['Item'])
            }
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Product not found'})
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

def list_products():
    print("Listing all products")
    try:
        # Inefficient full table scan that takes too long
        time.sleep(2)  # Simulated slow operation
        response = table.scan()
        items = response.get('Items', [])

        # Pagination handling (slow)
        while 'LastEvaluatedKey' in response:
            time.sleep(1)
            response = table.scan(ExclusiveStartKey=response['LastEvaluatedKey'])
            items.extend(response.get('Items', []))

        return {
            'statusCode': 200,
            'headers': {'Content-Type': 'application/json'},
            'body': json.dumps(items)
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
EOF

    # Create SAM template with planted issue (3s timeout)
    cat > "${TEMP_DIR}/template.yaml" << EOF
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Description: ShopFast Product Service Lambda

Globals:
  Function:
    Runtime: python3.11
    Timeout: 3
    MemorySize: 128

Resources:
  ProductServiceFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: ${STACK_PREFIX}-product-service-${ENVIRONMENT}
      Handler: product_handler.handler
      CodeUri: .
      Policies:
        - DynamoDBCrudPolicy:
            TableName: ${STACK_PREFIX}-products-${ENVIRONMENT}
      Environment:
        Variables:
          PRODUCTS_TABLE: ${STACK_PREFIX}-products-${ENVIRONMENT}
          ENVIRONMENT: ${ENVIRONMENT}
      Tags:
        Environment: ${ENVIRONMENT}

  NotificationHandlerFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: ${STACK_PREFIX}-notification-handler-${ENVIRONMENT}
      Handler: notification_handler.handler
      CodeUri: .
      Timeout: 30
      Policies:
        - SNSPublishMessagePolicy:
            TopicName: ${STACK_PREFIX}-notifications-${ENVIRONMENT}
        - SQSPollerPolicy:
            QueueName: ${STACK_PREFIX}-notifications-${ENVIRONMENT}
      Environment:
        Variables:
          NOTIFICATIONS_TOPIC: !Sub arn:aws:sns:\${AWS::Region}:\${AWS::AccountId}:${STACK_PREFIX}-notifications-${ENVIRONMENT}
          ENVIRONMENT: ${ENVIRONMENT}
      Events:
        SQSEvent:
          Type: SQS
          Properties:
            Queue: !Sub arn:aws:sqs:\${AWS::Region}:\${AWS::AccountId}:${STACK_PREFIX}-notifications-${ENVIRONMENT}
            BatchSize: 10
      Tags:
        Environment: ${ENVIRONMENT}

Outputs:
  ProductServiceArn:
    Description: Product Service Lambda ARN
    Value: !GetAtt ProductServiceFunction.Arn
  NotificationHandlerArn:
    Description: Notification Handler Lambda ARN
    Value: !GetAtt NotificationHandlerFunction.Arn
EOF

    # Notification handler with planted issue (missing message attributes)
    cat > "${TEMP_DIR}/notification_handler.py" << 'EOF'
import json
import boto3
import os

sns = boto3.client('sns')
TOPIC_ARN = os.environ.get('NOTIFICATIONS_TOPIC')

def handler(event, context):
    """Notification handler for processing order events."""
    print("Processing notification event")

    for record in event.get('Records', []):
        try:
            body = json.loads(record['body'])
            print(f"Processing: {body}")

            sns.publish(
                TopicArn=TOPIC_ARN,
                Message=json.dumps({
                    'notification': body,
                    'processed': True
                })
                # Missing MessageAttributes with eventType
            )

            print("Notification sent successfully")

        except Exception as e:
            print(f"Error processing record: {str(e)}")
            raise

    return {'statusCode': 200}
EOF

    # Deploy using SAM
    echo -e "${YELLOW}Building SAM application...${NC}"
    cd "${TEMP_DIR}"
    sam build

    echo -e "${YELLOW}Deploying SAM application...${NC}"
    echo Y | sam sync \
        --stack-name "${STACK_PREFIX}-lambda" \
        --region "${AWS_REGION}" \
        --s3-bucket "${SAM_BUCKET}" \
        --no-watch \
        --no-dependency-layer

    # Cleanup
    rm -rf "${TEMP_DIR}"
else
    # Deploy from starter code
    echo "Deploying from starter code..."
    cd "${STARTER_CODE}/lambdas/product-service"

    sam build
    echo Y | sam sync \
        --stack-name "${STACK_PREFIX}-lambda" \
        --region "${AWS_REGION}" \
        --s3-bucket "${SAM_BUCKET}" \
        --no-watch \
        --no-dependency-layer
fi

echo ""
echo -e "${GREEN}Lambda functions deployed successfully${NC}"
