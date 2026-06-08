#!/bin/bash
#
# ShopFast Environment Bootstrap Script (Serverless-Only)
# Deploys all serverless infrastructure and services for the course project
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color
CYAN='\033[0;36m'

# Timing instrumentation
declare -A TIMING_DATA
TIMING_ORDER=()

# Format duration in human-readable format
format_duration() {
    local seconds=$1
    local hours=$((seconds / 3600))
    local minutes=$(((seconds % 3600) / 60))
    local secs=$((seconds % 60))

    if [ $hours -gt 0 ]; then
        printf "%dh %dm %ds" $hours $minutes $secs
    elif [ $minutes -gt 0 ]; then
        printf "%dm %ds" $minutes $secs
    else
        printf "%ds" $secs
    fi
}

# Start timing a component
start_timer() {
    local component="$1"
    TIMING_DATA["${component}_start"]=$(date +%s)
    TIMING_ORDER+=("$component")
}

# Stop timing and display completion message
stop_timer() {
    local component="$1"
    local end_time=$(date +%s)
    local start_time=${TIMING_DATA["${component}_start"]}
    local duration=$((end_time - start_time))
    TIMING_DATA["${component}_duration"]=$duration
    local formatted=$(format_duration $duration)
    echo -e "${GREEN}✓ ${component} completed in ${formatted}${NC}"
}

# Print timing summary table
print_timing_summary() {
    local total_duration=$1
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  Deployment Timing Summary${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
    printf "%-40s %15s\n" "Component" "Duration"
    printf "%-40s %15s\n" "----------------------------------------" "---------------"

    for component in "${TIMING_ORDER[@]}"; do
        local duration=${TIMING_DATA["${component}_duration"]}
        local formatted=$(format_duration $duration)
        printf "%-40s %15s\n" "$component" "$formatted"
    done

    printf "%-40s %15s\n" "----------------------------------------" "---------------"
    local total_formatted=$(format_duration $total_duration)
    printf "${GREEN}%-40s %15s${NC}\n" "TOTAL" "$total_formatted"
    echo ""
}

# Configuration
STACK_PREFIX="shopfast"
AWS_REGION="${AWS_REGION:-us-east-1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ShopFast Environment Bootstrap${NC}"
echo -e "${GREEN}  (Serverless-Only Architecture)${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Region: ${AWS_REGION}"
echo "Stack Prefix: ${STACK_PREFIX}"
echo ""

# Start total deployment timer
BOOTSTRAP_START_TIME=$(date +%s)

# Function to wait for CloudFormation stack
wait_for_stack() {
    local stack_name=$1
    echo -e "${YELLOW}Waiting for stack ${stack_name} to complete...${NC}"
    aws cloudformation wait stack-create-complete --stack-name "$stack_name" --region "$AWS_REGION" 2>/dev/null || \
    aws cloudformation wait stack-update-complete --stack-name "$stack_name" --region "$AWS_REGION" 2>/dev/null
    echo -e "${GREEN}Stack ${stack_name} completed successfully${NC}"
}

# Function to check stack status and clean up failed stacks
check_stack_status() {
    local stack_name=$1
    local stack_status

    # Check if stack exists
    stack_status=$(aws cloudformation describe-stacks --stack-name "$stack_name" --region "$AWS_REGION" --query 'Stacks[0].StackStatus' --output text 2>/dev/null)

    if [ -z "$stack_status" ] || [ "$stack_status" == "None" ]; then
        echo "DOES_NOT_EXIST"
        return 0
    fi

    case "$stack_status" in
        ROLLBACK_COMPLETE|CREATE_FAILED|DELETE_FAILED)
            echo -e "${YELLOW}Stack ${stack_name} is in ${stack_status} state. Cleaning up...${NC}"
            aws cloudformation delete-stack --stack-name "$stack_name" --region "$AWS_REGION"
            echo -e "${YELLOW}Waiting for stack deletion to complete...${NC}"
            aws cloudformation wait stack-delete-complete --stack-name "$stack_name" --region "$AWS_REGION"
            echo -e "${GREEN}Failed stack ${stack_name} deleted successfully${NC}"
            echo "CLEANED_UP"
            ;;
        CREATE_COMPLETE|UPDATE_COMPLETE|UPDATE_ROLLBACK_COMPLETE)
            echo "EXISTS_HEALTHY"
            ;;
        *_IN_PROGRESS)
            echo -e "${RED}Stack ${stack_name} is currently in progress (${stack_status}). Please wait for it to complete.${NC}"
            exit 1
            ;;
        *)
            echo -e "${YELLOW}Stack ${stack_name} is in ${stack_status} state${NC}"
            echo "EXISTS_UNHEALTHY"
            ;;
    esac
}

# Function to deploy CloudFormation stack
deploy_stack() {
    local stack_name=$1
    local template_file=$2
    local parameters=${3:-""}

    echo -e "${YELLOW}Deploying stack: ${stack_name}${NC}"

    # Check stack status and handle failed stacks
    local status
    status=$(check_stack_status "$stack_name")

    case "$status" in
        DOES_NOT_EXIST|CLEANED_UP)
            echo "Creating new stack..."
            aws cloudformation create-stack \
                --stack-name "$stack_name" \
                --template-body "file://${SCRIPT_DIR}/templates/${template_file}" \
                --capabilities CAPABILITY_NAMED_IAM \
                --region "$AWS_REGION" \
                $parameters
            wait_for_stack "$stack_name"
            ;;
        EXISTS_HEALTHY)
            echo "Stack exists, checking for updates..."
            if aws cloudformation update-stack \
                --stack-name "$stack_name" \
                --template-body "file://${SCRIPT_DIR}/templates/${template_file}" \
                --capabilities CAPABILITY_NAMED_IAM \
                --region "$AWS_REGION" \
                $parameters 2>&1 | grep -q "No updates are to be performed"; then
                echo "No updates needed"
            else
                wait_for_stack "$stack_name"
            fi
            ;;
        EXISTS_UNHEALTHY)
            echo -e "${RED}Stack ${stack_name} is in an unhealthy state. Manual intervention may be required.${NC}"
            exit 1
            ;;
    esac
}

# Step 1: Deploy Network Infrastructure
echo ""
echo -e "${GREEN}Step 1/5: Deploying Network Infrastructure${NC}"
start_timer "Network Infrastructure"
deploy_stack "${STACK_PREFIX}-network" "network.yaml"
stop_timer "Network Infrastructure"

# Get VPC outputs for subsequent stacks
VPC_ID=$(aws cloudformation describe-stacks --stack-name "${STACK_PREFIX}-network" --query 'Stacks[0].Outputs[?OutputKey==`VpcId`].OutputValue' --output text --region "$AWS_REGION")
PRIVATE_SUBNETS=$(aws cloudformation describe-stacks --stack-name "${STACK_PREFIX}-network" --query 'Stacks[0].Outputs[?OutputKey==`PrivateSubnets`].OutputValue' --output text --region "$AWS_REGION")

echo "VPC ID: ${VPC_ID}"

# Step 2: Deploy Data Stores
echo ""
echo -e "${GREEN}Step 2/5: Deploying Data Stores (DynamoDB, ElastiCache)${NC}"
start_timer "Data Stores"
deploy_stack "${STACK_PREFIX}-data" "data.yaml" "--parameters ParameterKey=VpcId,ParameterValue=${VPC_ID} ParameterKey=PrivateSubnets,ParameterValue=\"${PRIVATE_SUBNETS}\""
stop_timer "Data Stores"

# Step 3: Deploy Messaging Infrastructure
echo ""
echo -e "${GREEN}Step 3/5: Deploying Messaging (SNS, SQS, EventBridge)${NC}"
start_timer "Messaging"
deploy_stack "${STACK_PREFIX}-messaging" "messaging.yaml"
stop_timer "Messaging"

# Step 4: Deploy Lambda Functions
echo ""
echo -e "${GREEN}Step 4/5: Deploying Lambda Functions${NC}"
start_timer "Lambda Functions"
chmod +x "${SCRIPT_DIR}/scripts/deploy-lambdas.sh"
"${SCRIPT_DIR}/scripts/deploy-lambdas.sh"
stop_timer "Lambda Functions"

# Step 5: Deploy Frontend
echo ""
echo -e "${GREEN}Step 5/5: Deploying Frontend${NC}"
start_timer "Frontend Stack"
deploy_stack "${STACK_PREFIX}-frontend" "frontend.yaml"
stop_timer "Frontend Stack"

start_timer "Frontend Deploy"
chmod +x "${SCRIPT_DIR}/scripts/deploy-frontend.sh"
"${SCRIPT_DIR}/scripts/deploy-frontend.sh"
stop_timer "Frontend Deploy"

# Seed Sample Data
echo ""
echo -e "${GREEN}Seeding Sample Data${NC}"
start_timer "Seed Data"
chmod +x "${SCRIPT_DIR}/scripts/seed-data.sh"
"${SCRIPT_DIR}/scripts/seed-data.sh"
stop_timer "Seed Data"

# Calculate total deployment time and print summary
BOOTSTRAP_END_TIME=$(date +%s)
TOTAL_DURATION=$((BOOTSTRAP_END_TIME - BOOTSTRAP_START_TIME))

# Output endpoints
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"

# Print timing summary
print_timing_summary $TOTAL_DURATION

# Get CloudFront URL
CLOUDFRONT_URL=$(aws cloudformation describe-stacks --stack-name "${STACK_PREFIX}-frontend" --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontUrl`].OutputValue' --output text --region "$AWS_REGION" 2>/dev/null || echo "Not available")

echo "Frontend URL: ${CLOUDFRONT_URL}"
echo ""
echo "Note: Lambda functions are invoked via AWS SDK/CLI, not HTTP endpoints."
echo "Run './scripts/verify-deployment.sh' to check all services"
echo ""

# Export environment variables
cat > "${SCRIPT_DIR}/env.sh" << EOF
export AWS_REGION="${AWS_REGION}"
export CLOUDFRONT_URL="${CLOUDFRONT_URL}"
export VPC_ID="${VPC_ID}"
EOF

echo "Environment variables saved to env.sh"
echo "Run 'source env.sh' to load them"
