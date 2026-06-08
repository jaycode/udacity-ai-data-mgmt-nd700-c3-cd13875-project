#!/bin/bash
#
# Verify ShopFast Deployment - Health checks for all serverless services
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

AWS_REGION="${AWS_REGION:-us-east-1}"
STACK_PREFIX="shopfast"
ENVIRONMENT="${ENVIRONMENT:-dev}"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ShopFast Deployment Verification${NC}"
echo -e "${GREEN}  (Serverless-Only Architecture)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

check_result() {
    local name=$1
    local status=$2
    local message=$3

    if [ "$status" == "PASS" ]; then
        echo -e "${GREEN}[PASS]${NC} ${name}: ${message}"
        ((PASS_COUNT++))
    elif [ "$status" == "WARN" ]; then
        echo -e "${YELLOW}[WARN]${NC} ${name}: ${message}"
        ((WARN_COUNT++))
    else
        echo -e "${RED}[FAIL]${NC} ${name}: ${message}"
        ((FAIL_COUNT++))
    fi
}

# 1. Check CloudFormation Stacks
echo ""
echo -e "${YELLOW}Checking CloudFormation Stacks...${NC}"

STACKS=("network" "data" "messaging" "frontend")
for stack in "${STACKS[@]}"; do
    STACK_STATUS=$(aws cloudformation describe-stacks \
        --stack-name "${STACK_PREFIX}-${stack}" \
        --query 'Stacks[0].StackStatus' \
        --output text --region "${AWS_REGION}" 2>/dev/null || echo "NOT_FOUND")

    if [ "$STACK_STATUS" == "CREATE_COMPLETE" ] || [ "$STACK_STATUS" == "UPDATE_COMPLETE" ]; then
        check_result "Stack: ${stack}" "PASS" "${STACK_STATUS}"
    elif [ "$STACK_STATUS" == "NOT_FOUND" ]; then
        check_result "Stack: ${stack}" "FAIL" "Not deployed"
    else
        check_result "Stack: ${stack}" "WARN" "${STACK_STATUS}"
    fi
done

# 2. Check Lambda Functions
echo ""
echo -e "${YELLOW}Checking Lambda Functions...${NC}"

LAMBDAS=("product-service" "notification-handler" "validate-catalog" "fetch-products" "update-catalog")
for lambda in "${LAMBDAS[@]}"; do
    LAMBDA_STATE=$(aws lambda get-function \
        --function-name "${STACK_PREFIX}-${lambda}-${ENVIRONMENT}" \
        --query 'Configuration.State' \
        --output text --region "${AWS_REGION}" 2>/dev/null || echo "NOT_FOUND")

    if [ "$LAMBDA_STATE" == "Active" ]; then
        check_result "Lambda: ${lambda}" "PASS" "Active"
    elif [ "$LAMBDA_STATE" == "NOT_FOUND" ]; then
        check_result "Lambda: ${lambda}" "WARN" "Not found (may be optional)"
    else
        check_result "Lambda: ${lambda}" "FAIL" "${LAMBDA_STATE}"
    fi
done

# 3. Check DynamoDB Tables
echo ""
echo -e "${YELLOW}Checking DynamoDB Tables...${NC}"

TABLES=("products")
for table in "${TABLES[@]}"; do
    TABLE_STATUS=$(aws dynamodb describe-table \
        --table-name "${STACK_PREFIX}-${table}-${ENVIRONMENT}" \
        --query 'Table.TableStatus' \
        --output text --region "${AWS_REGION}" 2>/dev/null || echo "NOT_FOUND")

    if [ "$TABLE_STATUS" == "ACTIVE" ]; then
        ITEM_COUNT=$(aws dynamodb scan \
            --table-name "${STACK_PREFIX}-${table}-${ENVIRONMENT}" \
            --select "COUNT" \
            --query 'Count' \
            --output text --region "${AWS_REGION}" 2>/dev/null || echo "0")
        check_result "DynamoDB: ${table}" "PASS" "Active (${ITEM_COUNT} items)"
    else
        check_result "DynamoDB: ${table}" "FAIL" "${TABLE_STATUS}"
    fi
done

# 4. Check ElastiCache Redis
echo ""
echo -e "${YELLOW}Checking ElastiCache...${NC}"

REDIS_STATUS=$(aws elasticache describe-cache-clusters \
    --cache-cluster-id "${STACK_PREFIX}-redis-${ENVIRONMENT}" \
    --query 'CacheClusters[0].CacheClusterStatus' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "NOT_FOUND")

if [ "$REDIS_STATUS" == "available" ]; then
    check_result "ElastiCache Redis" "PASS" "Available"
else
    check_result "ElastiCache Redis" "WARN" "${REDIS_STATUS} (used for caching optimization)"
fi

# 5. Check Lambda Function Invocation
echo ""
echo -e "${YELLOW}Checking Lambda Function Invocation...${NC}"

# Test Lambda invoke directly (not via HTTP - this architecture uses SDK invocation)
INVOKE_RESULT=$(aws lambda invoke \
    --function-name "shopfast-product-service-${ENVIRONMENT}" \
    --payload '{"path": "/products", "httpMethod": "GET"}' \
    --cli-binary-format raw-in-base64-out \
    /tmp/lambda-response.json \
    --query 'StatusCode' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "FAILED")

if [ "$INVOKE_RESULT" == "200" ]; then
    check_result "Lambda Invoke" "PASS" "Function responded successfully"
else
    check_result "Lambda Invoke" "WARN" "Function invoke returned ${INVOKE_RESULT} (may require VPC access)"
fi

# 6. Check CloudFront
echo ""
echo -e "${YELLOW}Checking CloudFront...${NC}"

CLOUDFRONT_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_PREFIX}-frontend" \
    --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontUrl`].OutputValue' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "")

if [ -n "$CLOUDFRONT_URL" ] && [ "$CLOUDFRONT_URL" != "None" ]; then
    check_result "CloudFront" "PASS" "${CLOUDFRONT_URL}"
else
    check_result "CloudFront" "FAIL" "URL not found"
fi

# 7. Check SNS Topics
echo ""
echo -e "${YELLOW}Checking SNS Topics...${NC}"

TOPICS=("product-events" "notifications")
for topic in "${TOPICS[@]}"; do
    TOPIC_ARN=$(aws sns list-topics \
        --query "Topics[?contains(TopicArn, '${STACK_PREFIX}-${topic}')].TopicArn" \
        --output text --region "${AWS_REGION}" 2>/dev/null || echo "")

    if [ -n "$TOPIC_ARN" ]; then
        check_result "SNS: ${topic}" "PASS" "Exists"
    else
        check_result "SNS: ${topic}" "FAIL" "Not found"
    fi
done

# 9. Check SQS Queues
echo ""
echo -e "${YELLOW}Checking SQS Queues...${NC}"

QUEUES=("product-processing" "notifications")
for queue in "${QUEUES[@]}"; do
    QUEUE_URL=$(aws sqs get-queue-url \
        --queue-name "${STACK_PREFIX}-${queue}-${ENVIRONMENT}" \
        --query 'QueueUrl' \
        --output text --region "${AWS_REGION}" 2>/dev/null || echo "")

    if [ -n "$QUEUE_URL" ]; then
        check_result "SQS: ${queue}" "PASS" "Exists"
    else
        check_result "SQS: ${queue}" "FAIL" "Not found"
    fi
done

# 10. Check EventBridge
echo ""
echo -e "${YELLOW}Checking EventBridge...${NC}"

EVENT_BUS=$(aws events describe-event-bus \
    --name "${STACK_PREFIX}-events-${ENVIRONMENT}" \
    --query 'Name' \
    --output text --region "${AWS_REGION}" 2>/dev/null || echo "NOT_FOUND")

if [ "$EVENT_BUS" != "NOT_FOUND" ]; then
    check_result "EventBridge" "PASS" "Event bus exists"
else
    check_result "EventBridge" "FAIL" "Event bus not found"
fi

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Verification Summary${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "Passed: ${GREEN}${PASS_COUNT}${NC}"
echo -e "Warnings: ${YELLOW}${WARN_COUNT}${NC}"
echo -e "Failed: ${RED}${FAIL_COUNT}${NC}"
echo ""

if [ $FAIL_COUNT -gt 0 ]; then
    echo -e "${RED}Some checks failed. Review the output above for details.${NC}"
    exit 1
elif [ $WARN_COUNT -gt 0 ]; then
    echo -e "${YELLOW}Deployment complete with warnings.${NC}"
    echo "Note: Some warnings are expected (planted issues for the course)."
    exit 0
else
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
fi
