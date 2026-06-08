#!/bin/bash
#
# ShopFast Environment Cleanup Script (Serverless-Only)
# Removes all infrastructure and resources
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
STACK_PREFIX="shopfast"
AWS_REGION="${AWS_REGION:-us-east-1}"
export AWS_PAGER=""

echo -e "${RED}========================================${NC}"
echo -e "${RED}  ShopFast Environment Cleanup${NC}"
echo -e "${RED}  (Serverless-Only Architecture)${NC}"
echo -e "${RED}========================================${NC}"
echo ""
echo -e "${YELLOW}WARNING: This will delete ALL resources including data!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Function to delete CloudFormation stack
delete_stack() {
    local stack_name=$1

    if aws cloudformation describe-stacks --stack-name "$stack_name" --region "$AWS_REGION" 2>/dev/null; then
        echo -e "${YELLOW}Deleting stack: ${stack_name}${NC}"
        aws cloudformation delete-stack --stack-name "$stack_name" --region "$AWS_REGION"
        echo "Waiting for stack deletion..."
        aws cloudformation wait stack-delete-complete --stack-name "$stack_name" --region "$AWS_REGION"
        echo -e "${GREEN}Stack ${stack_name} deleted${NC}"
    else
        echo "Stack ${stack_name} does not exist, skipping..."
    fi
}

# Empty S3 buckets before deleting
echo ""
echo -e "${YELLOW}Step 1/5: Emptying S3 Buckets${NC}"
FRONTEND_BUCKET=$(aws cloudformation describe-stacks --stack-name "${STACK_PREFIX}-frontend" --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' --output text --region "$AWS_REGION" 2>/dev/null || echo "")
if [ -n "$FRONTEND_BUCKET" ] && [ "$FRONTEND_BUCKET" != "None" ]; then
    aws s3 rm "s3://${FRONTEND_BUCKET}" --recursive 2>/dev/null || true
fi

# Delete stacks in reverse order of creation
echo ""
echo -e "${YELLOW}Step 2/5: Deleting Frontend Stack${NC}"
delete_stack "${STACK_PREFIX}-frontend"

echo ""
echo -e "${YELLOW}Step 3/5: Deleting Lambda Stack${NC}"
delete_stack "${STACK_PREFIX}-lambda"

echo ""
echo -e "${YELLOW}Step 4/5: Deleting Messaging, Data and Network Stacks${NC}"
delete_stack "${STACK_PREFIX}-messaging"
delete_stack "${STACK_PREFIX}-data"
delete_stack "${STACK_PREFIX}-network"

# Clean up orphaned resources not managed by CloudFormation
echo ""
echo -e "${YELLOW}Step 5/5: Cleaning Up Orphaned Resources${NC}"

# Delete orphaned Lambda function
echo "Deleting orphaned Lambda function..."
aws lambda delete-function --function-name shopfast-product-service-dev --region "$AWS_REGION" 2>/dev/null || echo "No orphaned Lambda function"

# Delete orphaned CloudWatch Log Groups
echo "Deleting orphaned CloudWatch Log Groups..."
aws logs delete-log-group --log-group-name /aws/lambda/shopfast-product-service-dev --region "$AWS_REGION" 2>/dev/null || echo "No orphaned Lambda log group"

# Delete orphaned DynamoDB tables
echo "Deleting orphaned DynamoDB tables..."
aws dynamodb delete-table --table-name shopfast-products-dev --region "$AWS_REGION" 2>/dev/null || echo "No orphaned products table"
aws dynamodb delete-table --table-name shopfast-orders-dev --region "$AWS_REGION" 2>/dev/null || echo "No orphaned orders table"

echo -e "${GREEN}Orphaned resources cleaned up${NC}"

# Clean up local files
rm -f env.sh 2>/dev/null || true

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Cleanup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
