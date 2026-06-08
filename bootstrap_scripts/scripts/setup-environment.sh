#!/bin/bash
#
# ShopFast Development Environment Setup
# Installs all required tools for Cloud9
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ShopFast Environment Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check if running on Amazon Linux 2023 (Cloud9)
if [ -f /etc/system-release ]; then
    echo "Detected Amazon Linux environment"
else
    echo -e "${YELLOW}Warning: This script is optimized for Cloud9/Amazon Linux${NC}"
fi

# Update system packages
echo -e "${YELLOW}Updating system packages...${NC}"
sudo yum update -y

# Install AWS CLI v2 (if not present)
echo -e "${YELLOW}Checking AWS CLI...${NC}"
if ! command -v aws &> /dev/null || ! aws --version | grep -q "aws-cli/2"; then
    echo "Installing AWS CLI v2..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip -q awscliv2.zip
    sudo ./aws/install --update
    rm -rf aws awscliv2.zip
fi
aws --version

# Install AWS SAM CLI
echo -e "${YELLOW}Installing AWS SAM CLI...${NC}"
if ! command -v sam &> /dev/null; then
    pip3 install aws-sam-cli
fi
sam --version

# Install Python 3.11
echo -e "${YELLOW}Checking Python 3.11...${NC}"
if ! command -v python3.11 &> /dev/null; then
    echo "Installing Python 3.11..."
    sudo yum install -y python3.11 python3.11-pip
fi
python3.11 --version

# Install Node.js 22 LTS
echo -e "${YELLOW}Installing Node.js 22 LTS...${NC}"
if ! command -v node &> /dev/null || ! node --version | grep -q "v22"; then
    curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
    sudo yum install -y nodejs
fi
node --version
npm --version

# Install jq for JSON processing
echo -e "${YELLOW}Installing jq...${NC}"
if ! command -v jq &> /dev/null; then
    sudo yum install -y jq
fi
jq --version

# Install git (usually pre-installed)
echo -e "${YELLOW}Checking git...${NC}"
if ! command -v git &> /dev/null; then
    sudo yum install -y git
fi
git --version

# Verify AWS credentials
echo ""
echo -e "${YELLOW}Verifying AWS credentials...${NC}"
if aws sts get-caller-identity &> /dev/null; then
    echo -e "${GREEN}AWS credentials configured successfully${NC}"
    aws sts get-caller-identity
else
    echo -e "${RED}Warning: AWS credentials not configured${NC}"
    echo "Please configure AWS credentials using 'aws configure' or IAM role"
fi

# Set default region if not set
if [ -z "$AWS_REGION" ]; then
    export AWS_REGION="us-east-1"
    echo "export AWS_REGION=\"us-east-1\"" >> ~/.bashrc
    echo "Set default AWS_REGION to us-east-1"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Installed tools:"
echo "  - AWS CLI v2"
echo "  - AWS SAM CLI"
echo "  - Python 3.11"
echo "  - Node.js 22 LTS"
echo "  - jq"
echo "  - git"
echo ""
echo -e "${YELLOW}Note: You may need to restart your terminal for all changes to take effect${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run 'source ~/.bashrc')"
echo "  2. Run './bootstrap.sh' to deploy the environment"
