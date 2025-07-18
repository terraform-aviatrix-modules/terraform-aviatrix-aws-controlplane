# Aviatrix Control Plane Deployment - AWS CloudShell Launcher

## Overview

This directory contains a Bash script that provides a user-friendly wrapper around the `terraform-aviatrix-aws-controlplane` Terraform module. It's designed to guide users through deploying a complete Aviatrix control plane in AWS without requiring deep Terraform knowledge.

## Who should (not) use it?

### ✅ **You SHOULD use this if:**
- You want to quickly deploy Aviatrix with minimal setup complexity
- You prefer a simple, guided installation process without Terraform expertise
- You don't need to manage infrastructure changes after initial deployment
- You're comfortable with a "deploy and forget" approach
- You want to get started quickly without learning Terraform specifics
- You need a one-time deployment (for any environment: production, staging, demos, or testing)

### ❌ **You should NOT use this if:**
- You need to manage ongoing infrastructure changes and updates through IaC
- You want to maintain Terraform state for future modifications
- You need to integrate with existing Terraform workflows or CI/CD pipelines
- You require repeatable, automated deployments across multiple environments
- You want to track infrastructure changes over time
- You plan to make frequent configuration changes to the deployment
- You need infrastructure-as-code practices with version control

### 🔧 **Alternative: Use the Terraform Module Directly**
If this script doesn't meet your needs, use the underlying `terraform-aviatrix-aws-controlplane` Terraform module directly:
- Full control over Terraform state management
- Integration with existing Terraform workflows
- Version control and infrastructure-as-code practices
- Customizable configuration beyond script parameters
- Suitable for CI/CD pipelines and automated deployments

## What Gets Deployed

The script deploys and configures:

- **Aviatrix Controller EC2 instance** - The main control plane VM
- **Controller initialization** - Automatic setup and configuration
- **IAM roles and policies** - Required permissions for API access
- **AWS account onboarding** - Connects your AWS account to the controller
- **Optional CoPilot deployment** - Analytics and monitoring platform
- **Security groups** - Properly configured network access controls

## Prerequisites

- **AWS CloudShell access** (recommended) or local AWS CLI setup
- **AWS CLI authentication** with sufficient permissions
- **IAM permissions** to create roles, policies, and EC2 instances
- **Valid Aviatrix customer license ID**

### Required AWS Permissions

Your AWS user/role needs the following permissions:
- EC2 full access (for instances, security groups, VPCs)
- IAM full access (for creating roles and policies)
- CloudFormation access (used by Terraform)
- Systems Manager access (for parameter store)

## Quick Start

### Option 1: Interactive Mode (Recommended)
```bash
# Download and run the script
curl -O https://raw.githubusercontent.com/terraform-aviatrix-modules/terraform-aviatrix-aws-controlplane/refs/heads/main/cloudshell/deploy-aviatrix-controlplane.sh
chmod +x deploy-aviatrix-controlplane.sh
./deploy-aviatrix-controlplane.sh
```

### Option 2: Automated Mode
```bash
# Download and run the script
curl -O https://raw.githubusercontent.com/terraform-aviatrix-modules/terraform-aviatrix-aws-controlplane/refs/heads/main/cloudshell/deploy-aviatrix-controlplane.sh
chmod +x deploy-aviatrix-controlplane.sh
./deploy-aviatrix-controlplane.sh \
  --deployment-name "my-avx-prod" \
  --region "us-east-1" \
  --admin-email "admin@company.com" \
  --admin-password "MySecure123!" \
  --customer-id "aviatrix-abc-123456"
```

### Option 3: With CoPilot
```bash
# Download and run the script
curl -O https://raw.githubusercontent.com/terraform-aviatrix-modules/terraform-aviatrix-aws-controlplane/refs/heads/main/cloudshell/deploy-aviatrix-controlplane.sh
chmod +x deploy-aviatrix-controlplane.sh
./deploy-aviatrix-controlplane.sh \
  --deployment-name "my-avx-prod" \
  --include-copilot \
  --region "us-east-1"
```

## Script Parameters

| Parameter | Short | Description | Required | Example |
|-----------|-------|-------------|----------|---------|
| `--deployment-name` | `-n` | Unique deployment name | Yes | `my-avx-prod` |
| `--region` | `-r` | AWS region | Yes | `us-east-1` |
| `--admin-email` | `-e` | Controller admin email | Yes | `admin@company.com` |
| `--admin-password` | `-p` | Controller admin password | Yes | `MySecure123!` |
| `--customer-id` | `-c` | Aviatrix customer license ID | Yes | `aviatrix-abc-123456` |
| `--include-copilot` | `-C` | Deploy CoPilot analytics | No | (flag only) |
| `--incoming-cidrs` | `-i` | Your public IP/CIDR | No | `203.0.113.25/32` |
| `--mgmt-ips` | `-m` | Additional management IPs | No | `192.168.1.0/24,10.0.0.50` |
| `--skip-confirmation` | `-y` | Skip prompts (automation) | No | (flag only) |
| `--action` | `-a` | Terraform action | No | `plan/apply/destroy` |
| `--test-mode` | `-t` | Validate without deploying | No | (flag only) |
| `--help` | `-h` | Show help message | No | (flag only) |

## Password Requirements

The admin password must meet these criteria:
- Minimum 8 characters
- At least one letter (a-z, A-Z)
- At least one number (0-9)
- At least one symbol (!@#$%^&*)

## Supported AWS Regions

## Supported AWS Regions

The script supports deployment in all standard AWS regions:

**United States:**
- us-east-1 (N. Virginia)
- us-east-2 (Ohio) 
- us-west-1 (N. California)
- us-west-2 (Oregon)

**Canada:**
- ca-central-1 (Central Canada)
- ca-west-1 (Western Canada)

**South America:**
- sa-east-1 (São Paulo)

**Europe:**
- eu-central-1 (Frankfurt)
- eu-central-2 (Zurich)
- eu-west-1 (Ireland)
- eu-west-2 (London)
- eu-west-3 (Paris)
- eu-north-1 (Stockholm)
- eu-south-1 (Milan)
- eu-south-2 (Spain)

**Asia Pacific:**
- ap-east-1 (Hong Kong)
- ap-south-1 (Mumbai)
- ap-south-2 (Hyderabad)
- ap-southeast-1 (Singapore)
- ap-southeast-2 (Sydney)
- ap-southeast-3 (Jakarta)
- ap-southeast-4 (Melbourne)
- ap-northeast-1 (Tokyo)
- ap-northeast-2 (Seoul)
- ap-northeast-3 (Osaka)

**Middle East & Africa:**
- me-south-1 (Bahrain)
- me-central-1 (UAE)
- af-south-1 (Cape Town)

**Note:** AWS China regions (cn-north-1, cn-northwest-1) and AWS GovCloud regions (us-gov-east-1, us-gov-west-1) require special AWS accounts and are not included in this script.

## Deployment Time

- **Controller only:** ~10-15 minutes
- **Controller + CoPilot:** ~15-20 minutes

## Output Information

After successful deployment, the script provides:
- Controller public IP address and login URL
- CoPilot public IP address and login URL (if deployed)
- Login credentials (username: `admin`, password: what you specified)
- Next steps and access information

## Advanced Usage

### Test Mode
Validate your configuration without actually deploying:
```bash
./deploy-aviatrix-controlplane.sh --test-mode
```

### Planning Before Apply
See what resources will be created:
```bash
./deploy-aviatrix-controlplane.sh --action plan
```

### Destroying Deployment
Remove all deployed resources:
```bash
./deploy-aviatrix-controlplane.sh --action destroy --deployment-name "my-avx-prod"
```

### Custom Management Access
Specify additional IP addresses that should have access:
```bash
./deploy-aviatrix-controlplane.sh --mgmt-ips "192.168.1.100/32,10.0.0.0/8"
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**
   ```bash
   aws sts get-caller-identity  # Verify AWS CLI auth
   ```

2. **Permission Denied**
   - Check IAM permissions
   - Ensure you have EC2 and IAM full access

3. **Region Not Supported**
   - Use one of the supported regions listed above
   - Check if Aviatrix marketplace offerings are available in your region

4. **Deployment Timeout**
   - Check EC2 service health in AWS console
   - Verify internet connectivity from CloudShell

### Getting Help

1. **Script Help:** `./deploy-aviatrix-controlplane.sh --help`
2. **Aviatrix Documentation:** https://docs.aviatrix.com
3. **Aviatrix Support:** https://support.aviatrix.com
4. **AWS CloudShell Documentation:** https://docs.aws.amazon.com/cloudshell/

### Log Files

If deployment fails, check:
- Terraform logs in `./aviatrix-deployment/`
- AWS CloudShell session logs
- EC2 instance logs in AWS console

## Security Considerations

- Only specified IP addresses can access the controller and CoPilot
- All sensitive information is handled securely
- IAM roles follow least privilege principles
- Network security groups are configured with minimal required access
- **Important:** After deployment, remove the CloudShell IP from the controller's security group and ensure only your actual management IPs have access

## Next Steps After Deployment

1. Access the Controller at the provided URL
2. Login with username `admin` and your specified password
3. Your AWS account is already onboarded and ready to use
4. Start deploying Aviatrix transit gateways and spoke gateways
5. If CoPilot was deployed, access it for network analytics and monitoring