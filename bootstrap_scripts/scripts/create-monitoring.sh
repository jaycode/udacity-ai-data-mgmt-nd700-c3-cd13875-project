#!/bin/bash
#
# Create ShopFast operational dashboard, alarms, and optional SNS email subscription.
#

set -euo pipefail

AWS_REGION="${AWS_REGION:-us-east-1}"
STACK_PREFIX="shopfast"
ENVIRONMENT="${ENVIRONMENT:-dev}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DASHBOARD_FILE="${PROJECT_ROOT}/../starter_code/observability/dashboard.json"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
TOPIC_ARN="arn:aws:sns:${AWS_REGION}:${ACCOUNT_ID}:${STACK_PREFIX}-notifications-${ENVIRONMENT}"

echo "Creating CloudWatch dashboard..."
aws cloudwatch put-dashboard \
  --dashboard-name "ShopFast-MVP-Dashboard" \
  --dashboard-body "file://${DASHBOARD_FILE}" \
  --region "${AWS_REGION}"

if [ -n "${SNS_ALERT_EMAIL:-}" ]; then
  echo "Creating email subscription for ${SNS_ALERT_EMAIL}..."
  aws sns subscribe \
    --topic-arn "${TOPIC_ARN}" \
    --protocol email \
    --notification-endpoint "${SNS_ALERT_EMAIL}" \
    --region "${AWS_REGION}" >/dev/null
  echo "Check ${SNS_ALERT_EMAIL} and confirm the SNS subscription before taking the final screenshot."
fi

echo "Creating CloudWatch alarms..."
aws cloudwatch put-metric-alarm \
  --alarm-name "ShopFast-dev-ProductService-Errors" \
  --alarm-description "Alarm when the product service reports Lambda errors." \
  --namespace "AWS/Lambda" \
  --metric-name "Errors" \
  --dimensions Name=FunctionName,Value="${STACK_PREFIX}-product-service-${ENVIRONMENT}" \
  --statistic Sum \
  --period 60 \
  --evaluation-periods 1 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "${TOPIC_ARN}" \
  --region "${AWS_REGION}"

aws cloudwatch put-metric-alarm \
  --alarm-name "ShopFast-dev-ProductService-Duration" \
  --alarm-description "Alarm when product service average duration approaches the 10 second timeout." \
  --namespace "AWS/Lambda" \
  --metric-name "Duration" \
  --dimensions Name=FunctionName,Value="${STACK_PREFIX}-product-service-${ENVIRONMENT}" \
  --statistic Average \
  --period 60 \
  --evaluation-periods 2 \
  --threshold 8000 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "${TOPIC_ARN}" \
  --region "${AWS_REGION}"

aws cloudwatch put-metric-alarm \
  --alarm-name "ShopFast-dev-DynamoDB-Throttling" \
  --alarm-description "Alarm on DynamoDB read throttling for the products table." \
  --namespace "AWS/DynamoDB" \
  --metric-name "ReadThrottleEvents" \
  --dimensions Name=TableName,Value="${STACK_PREFIX}-products-${ENVIRONMENT}" \
  --statistic Sum \
  --period 60 \
  --evaluation-periods 1 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --treat-missing-data notBreaching \
  --alarm-actions "${TOPIC_ARN}" \
  --region "${AWS_REGION}"

echo "Monitoring resources are ready."
