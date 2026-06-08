# ShopFast Environment Bootstrap Scripts

This directory contains scripts and CloudFormation templates to deploy the ShopFast e-commerce platform for the course project.

## Cloud9 Setup Instructions

### Step 1: Create Cloud9 Environment

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

### Step 2: Open Cloud9 in the browser

1.  Now that you have created the environment, you can access Cloud9 from the Cloud9 service in the AWS Console.
2.  Select the environment you just created and click **Open in Cloud9**
3.  You should now be in the Cloud9 IDE, here's is a quick overview of what Cloud9 is: 
    -  The Cloud9 IDE is an AWS cli-based integrated development environment (IDE) that lets you write, run, and debug code in your browser.
    - Think of it as VS Code but running in your AWS cloud environment.
    - You can use the Cloud9 IDE to write, run, and debug your code, and to interact with AWS services.
    - We will be using the Cloud9 IDE to both bootstrap our environment and to complete the project. 

### Step 3: Clone the Repository
1. Once the Cloud9 IDE is open, you can use the terminal at the bottom of the IDE to clone the repository.
2. Click inside the bash terminal (lower right corner of the console) and paste the following commands:
  - `git clone https://github.com/dyer-innovation/cd14940-troubleshooting-and-optimization-in-aws-for-developers.git`
    - Note: This command will prompt you for your GitHub username and password. 
    - If you have not created a GitHub token, you can create one [here](https://github.com/settings/tokens/new?scopes=repo&description=cd14940-troubleshooting-and-optimization-in-aws-for-developers).
  - `cd cd14940-troubleshooting-and-optimization-in-aws-for-developers/project/bootstrap_scripts`

### Step 4: Install Dependencies
- To install the dependencies run the following commands:
  - `chmod +x scripts/setup-environment.sh`
  - `bash scripts/setup-environment.sh`
- **Note:** The script takes about 5 minutes to run.
- This script will install:
  - AWS SAM CLI
  - uv (Python package manager)
  - Node.js 24+
- Reload the terminal by either running `source ~/.bashrc` or opening a new terminal window

### Step 5: Bootstrap the Environment
- Run the following commands to bootstrap the environment:
  - `chmod +x bootstrap.sh`
  - `bash bootstrap.sh` 
- The bootstrap process takes approximately 10-15 minutes and will:
  1. Create networking infrastructure (VPC, subnets, security groups)
  2. Deploy data stores (DynamoDB, ElastiCache)
  3. Set up messaging (SNS, SQS, EventBridge)
  4. Deploy Lambda functions via SAM
  5. Configure CloudFront
  6. Deploy the React frontend
  7. Seed sample data
- You can view progress in the CloudFormation console

### Step 6: Verify Deployment
```bash
# Run verification script
./scripts/verify-deployment.sh
```

## Directory Structure

```
bootstrap_scripts/
├── README.md                    # This file
├── bootstrap.sh                 # Main orchestration script
├── cleanup.sh                   # Teardown script
├── templates/                   # CloudFormation templates
│   ├── network.yaml            # VPC, subnets, security groups
│   ├── data.yaml               # DynamoDB, ElastiCache
│   ├── messaging.yaml          # SNS, SQS, EventBridge
│   └── frontend.yaml           # S3 and CloudFront
└── scripts/                    # Helper scripts
    ├── setup-environment.sh    # Install dependencies
    ├── deploy-lambdas.sh       # Deploy Lambda functions via SAM
    ├── deploy-frontend.sh      # Build and deploy React frontend
    ├── seed-data.sh            # Populate sample data
    └── verify-deployment.sh    # Health check all services
```

## Environment Variables

After bootstrap completes, run the following command to set the environment variables:

```bash
# Export these for use in the project
export CLOUDFRONT_URL=$(aws cloudformation describe-stacks --stack-name shopfast-frontend --query 'Stacks[0].Outputs[?OutputKey==`CloudFrontUrl`].OutputValue' --output text)
export REDIS_ENDPOINT=$(aws cloudformation describe-stacks --stack-name shopfast-data --query 'Stacks[0].Outputs[?OutputKey==`RedisEndpoint`].OutputValue' --output text)
```

You can confirm the outputs are all set by running the following command:

```bash
printenv | grep CLOUDFRONT_URL
printenv | grep REDIS_ENDPOINT
printenv | grep AWS_REGION
```

Note: Lambda functions are invoked via AWS SDK/CLI, not HTTP endpoints. 

Run `source ~/.bashrc` to set these in your terminal following sessions.

## Cleanup

To remove all resources when done:

```bash
./cleanup.sh
```

**Warning**: This will delete all resources including data. Make sure to export any work you want to keep.

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| SAM build fails | Ensure Python 3.11 is installed: `python3 --version` |
| Lambda deployment timeout | Check CloudFormation events for specific errors |
| Function URL CORS errors | Verify CORS configuration in Lambda template |
| DynamoDB access denied | Check Lambda execution role permissions |

### Getting Help

1. Check CloudFormation events in AWS Console for deployment errors
2. Review CloudWatch Logs for Lambda function errors
3. Check Lambda Function URL configuration for CORS issues
4. Contact course support for environment-specific problems
