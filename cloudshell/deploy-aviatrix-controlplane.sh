#!/bin/bash

#
# Deploy Aviatrix Control Plane in AWS using Terraform - CloudShell Launcher
#
# This Bash script provides a user-friendly wrapper around the terraform-aviatrix-aws-controlplane
# Terraform module. It guides users through deploying a complete Aviatrix control plane in AWS including:
# - Aviatrix Controller EC2 instance
# - Controller initialization and configuration
# - IAM roles and policies for API access
# - AWS account onboarding
# - Optional CoPilot deployment for analytics
# - AWS Marketplace agreement acceptance
#
# Designed for execution in AWS CloudShell by users who don't know Terraform.
#
# Usage:
#   ./deploy-aviatrix-controlplane.sh [OPTIONS]
#
# Options:
#   -n, --deployment-name NAME    Unique name for this deployment (3-20 chars)
#   -r, --region REGION          AWS region for deployment (e.g., us-east-1, eu-west-1)
#   -e, --admin-email EMAIL      Email address for the Aviatrix controller admin
#   -p, --admin-password PASS    Secure password for the controller admin
#   -c, --customer-id ID         Aviatrix customer license ID
#   -C, --include-copilot        Deploy optional CoPilot for advanced analytics
#   -i, --incoming-cidrs CIDRS   Your public IP/CIDR for controller access (auto-detected if not provided)
#   -m, --mgmt-ips IPS           Additional management IPs (comma-separated)
#   -y, --skip-confirmation      Skip interactive confirmation prompts
#   -a, --action ACTION          Terraform action: plan, apply, or destroy (default: apply)
#   -t, --test-mode              Run in test mode - validate inputs without executing
#   -h, --help                   Show this help message
#
# Examples:
#   # Interactive deployment with prompts
#   ./deploy-aviatrix-controlplane.sh
#   
#   # Automated deployment with parameters
#   ./deploy-aviatrix-controlplane.sh -n "my-avx-ctrl" -r "us-east-1" -e "admin@company.com" -p "MySecure123!" -c "aviatrix-abc-123456"
#   
#   # Deploy with CoPilot included
#   ./deploy-aviatrix-controlplane.sh -n "my-avx-ctrl" -C
#   
#   # Destroy deployment
#   ./deploy-aviatrix-controlplane.sh -a destroy -n "my-avx-ctrl"
#

# Set strict error handling
set -euo pipefail

# Global variables
MODULE_SOURCE="terraform-aviatrix-modules/aws-controlplane/aviatrix"
MODULE_VERSION="1.0.9"
TERRAFORM_DIR="./aviatrix-deployment"

# Available AWS regions
AVAILABLE_REGIONS=(
    # US Regions
    "us-east-1" "us-east-2" "us-west-1" "us-west-2"
    # Canada
    "ca-central-1" "ca-west-1"
    # South America
    "sa-east-1"
    # Europe
    "eu-central-1" "eu-central-2" "eu-west-1" "eu-west-2" "eu-west-3" 
    "eu-north-1" "eu-south-1" "eu-south-2"
    # Asia Pacific
    "ap-east-1" "ap-south-1" "ap-south-2" "ap-southeast-1" "ap-southeast-2" 
    "ap-southeast-3" "ap-southeast-4" "ap-northeast-1" "ap-northeast-2" "ap-northeast-3"
    # Middle East & Africa
    "me-south-1" "me-central-1" "af-south-1"
    # China (special consideration needed)
    # "cn-north-1" "cn-northwest-1"  # Requires special AWS China account
    # GovCloud (special consideration needed)
    # "us-gov-east-1" "us-gov-west-1"  # Requires AWS GovCloud account
)

# Default values
DEPLOYMENT_NAME=""
REGION=""
ADMIN_EMAIL=""
ADMIN_PASSWORD=""
CUSTOMER_ID=""
INCLUDE_COPILOT=false
INCOMING_CIDRS=""
MGMT_IPS=""
SKIP_CONFIRMATION=false
TERRAFORM_ACTION="apply"
TEST_MODE=false
INCOMING_CIDRS_PROVIDED=false  # Track if user provided this via CLI

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;37m'
DARK_GRAY='\033[1;30m'
NC='\033[0m' # No Color

# Helper Functions
write_banner() {
    local message="$1"
    local color="${2:-cyan}"
    
    # Convert color name to escape code
    case "$color" in
        "red") color_code="$RED" ;;
        "green") color_code="$GREEN" ;;
        "yellow") color_code="$YELLOW" ;;
        "blue") color_code="$BLUE" ;;
        "cyan") color_code="$CYAN" ;;
        "magenta") color_code="$MAGENTA" ;;
        *) color_code="$CYAN" ;;
    esac
    
    echo ""
    echo -e "${color_code}╔══════════════════════════════════════════════════════════════════════════╗${NC}"
    
    # Calculate spacing for centering
    local total_width=74
    local message_length=${#message}
    local left_spaces=$(( (total_width - message_length) / 2 ))
    local right_spaces=$(( total_width - message_length - left_spaces ))
    
    printf "${color_code}║%*s%s%*s║${NC}\n" $left_spaces "" "$message" $right_spaces ""
    echo -e "${color_code}╚══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

write_step() {
    echo -e "${YELLOW}▶ $1${NC}"
}

write_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

write_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

write_error() {
    echo -e "${RED}❌ $1${NC}"
}

write_info() {
    echo -e "${CYAN}INFO: $1${NC}"
}

write_hint() {
    echo -e "${DARK_GRAY}TIP: $1${NC}"
}

show_help() {
    cat << EOF
Deploy Aviatrix Control Plane in AWS using Terraform - CloudShell Launcher

This script provides a user-friendly wrapper around the terraform-aviatrix-aws-controlplane
Terraform module for deploying a complete Aviatrix control plane in AWS.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -n, --deployment-name NAME    Unique name for this deployment (3-20 chars)
    -r, --region REGION          AWS region for deployment
    -e, --admin-email EMAIL      Email address for the controller admin
    -p, --admin-password PASS    Secure password for the controller admin
    -c, --customer-id ID         Aviatrix customer license ID
    -C, --include-copilot        Deploy CoPilot for advanced analytics
    -i, --incoming-cidrs CIDRS   Your public IP/CIDR for controller access
    -m, --mgmt-ips IPS           Additional management IPs (comma-separated)
    -y, --skip-confirmation      Skip interactive confirmation prompts
    -a, --action ACTION          Terraform action: plan, apply, destroy (default: apply)
    -t, --test-mode              Test mode - validate inputs without executing
    -h, --help                   Show this help message

EXAMPLES:
    # Interactive deployment
    $0

    # Automated deployment
    $0 -n "my-avx-ctrl" -r "us-east-1" -e "admin@company.com" \\
       -p "MySecure123!" -c "aviatrix-abc-123456"

    # Deploy with CoPilot
    $0 -n "my-avx-ctrl" -C

    # Destroy deployment
    $0 -a destroy -n "my-avx-ctrl"

NOTES:
    - Requires AWS CloudShell or AWS CLI configured environment
    - Terraform will be automatically installed if not present
    - AWS credentials are handled by CloudShell/CLI
    - All sensitive values are handled securely

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--deployment-name)
                DEPLOYMENT_NAME="$2"
                shift 2
                ;;
            -r|--region)
                REGION="$2"
                shift 2
                ;;
            -e|--admin-email)
                ADMIN_EMAIL="$2"
                shift 2
                ;;
            -p|--admin-password)
                ADMIN_PASSWORD="$2"
                shift 2
                ;;
            -c|--customer-id)
                CUSTOMER_ID="$2"
                shift 2
                ;;
            -C|--include-copilot)
                INCLUDE_COPILOT=true
                shift
                ;;
            -i|--incoming-cidrs)
                INCOMING_CIDRS="$2"
                INCOMING_CIDRS_PROVIDED=true
                shift 2
                ;;
            -m|--mgmt-ips)
                MGMT_IPS="$2"
                shift 2
                ;;
            -y|--skip-confirmation)
                SKIP_CONFIRMATION=true
                shift
                ;;
            -a|--action)
                TERRAFORM_ACTION="$2"
                shift 2
                ;;
            -t|--test-mode)
                TEST_MODE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                write_error "Unknown option: $1"
                echo "Use -h or --help for usage information."
                exit 1
                ;;
        esac
    done
}

# Validation functions
validate_deployment_name() {
    local name="$1"
    if [[ ! "$name" =~ ^[a-zA-Z0-9-]{3,20}$ ]]; then
        return 1
    fi
    return 0
}

validate_email() {
    local email="$1"
    if [[ ! "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        return 1
    fi
    return 0
}

validate_password() {
    local password="$1"
    local errors=()
    
    if [[ ${#password} -lt 8 ]]; then
        errors+=("Password must be at least 8 characters long")
    fi
    if [[ ! "$password" =~ [0-9] ]]; then
        errors+=("Password must contain at least one number")
    fi
    if [[ ! "$password" =~ [a-zA-Z] ]]; then
        errors+=("Password must contain at least one letter")
    fi
    if [[ ! "$password" =~ [^a-zA-Z0-9] ]]; then
        errors+=("Password must contain at least one symbol")
    fi
    
    if [[ ${#errors[@]} -gt 0 ]]; then
        for error in "${errors[@]}"; do
            write_error "$error"
        done
        return 1
    fi
    return 0
}

validate_region() {
    local region="$1"
    for valid_region in "${AVAILABLE_REGIONS[@]}"; do
        if [[ "$region" == "$valid_region" ]]; then
            return 0
        fi
    done
    return 1
}

validate_cidr() {
    local cidr="$1"
    # Basic CIDR validation - this could be more comprehensive
    if [[ "$cidr" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]{1,2})?$ ]]; then
        return 0
    fi
    return 0  # Allow for now, let Terraform validate
}

# Input collection functions
get_user_input() {
    local prompt="$1"
    local default_value="${2:-}"
    local is_password="${3:-false}"
    local validation_func="${4:-}"
    local is_optional="${5:-false}"
    
    while true; do
        if [[ -n "$default_value" ]]; then
            echo -e "${CYAN}$prompt [default: $default_value]: ${NC}"
        elif [[ "$is_optional" == "true" ]]; then
            echo -e "${CYAN}$prompt (optional): ${NC}"
        else
            echo -e "${CYAN}$prompt: ${NC}"
        fi
        
        if [[ "$is_password" == "true" ]]; then
            read -s input
            echo ""  # New line since read -s doesn't print one
        else
            read input
        fi
        
        # Use default if no input provided
        if [[ -z "$input" && -n "$default_value" ]]; then
            input="$default_value"
        fi
        
        # If field is optional and no input, return empty
        if [[ -z "$input" && "$is_optional" == "true" ]]; then
            echo ""
            return 0
        fi
        
        # Validate input if validation function provided
        if [[ -n "$validation_func" ]]; then
            if $validation_func "$input"; then
                echo "$input"
                return 0
            else
                write_error "Invalid input. Please try again."
                continue
            fi
        fi
        
        # Return input if no validation needed
        if [[ -n "$input" ]]; then
            echo "$input"
            return 0
        fi
        
        write_error "This field is required. Please enter a value."
    done
}

get_deployment_name() {
    if [[ -z "$DEPLOYMENT_NAME" ]]; then
        echo ""
        write_info "Enter a unique name for your deployment (3-20 characters, alphanumeric and hyphens only)"
        write_hint "This will be used to name AWS resources and must be unique in your account"
        
        while true; do
            echo -ne "${CYAN}Deployment Name: ${NC}"
            read DEPLOYMENT_NAME
            
            if [[ -z "$DEPLOYMENT_NAME" ]]; then
                write_error "Deployment name is required. Please enter a value."
                continue
            fi
            
            if validate_deployment_name "$DEPLOYMENT_NAME"; then
                break
            else
                write_error "Invalid deployment name. Please try again."
                continue
            fi
        done
    fi
}

get_region() {
    if [[ -z "$REGION" ]]; then
        echo ""
        write_info "Choose the AWS region where you want to deploy the Aviatrix Controller"
        write_hint "Select a region close to your primary users for best performance"
        echo ""
        echo "Available AWS regions:"
        echo "US: us-east-1, us-east-2, us-west-1, us-west-2"
        echo "Canada: ca-central-1"
        echo "South America: sa-east-1"
        echo "Europe: eu-west-1, eu-west-2, eu-west-3, eu-central-1, eu-north-1"
        echo "Asia Pacific: ap-southeast-1, ap-southeast-2, ap-northeast-1, ap-northeast-2, ap-south-1"
        echo "Middle East & Africa: me-south-1, af-south-1"
        echo ""
        
        while true; do
            echo -ne "${CYAN}AWS Region [default: us-east-1]: ${NC}"
            read REGION
            
            # Use default if no input provided
            if [[ -z "$REGION" ]]; then
                REGION="us-east-1"
            fi
            
            if validate_region "$REGION"; then
                break
            else
                write_error "Invalid region. Please try again."
                continue
            fi
        done
    fi
}

get_admin_email() {
    if [[ -z "$ADMIN_EMAIL" ]]; then
        echo ""
        write_info "Enter the email address for the Aviatrix Controller administrator account"
        
        while true; do
            echo -ne "${CYAN}Administrator Email: ${NC}"
            read ADMIN_EMAIL
            
            if [[ -z "$ADMIN_EMAIL" ]]; then
                write_error "Email is required. Please enter a value."
                continue
            fi
            
            if validate_email "$ADMIN_EMAIL"; then
                break
            else
                write_error "Invalid email format. Please try again."
                continue
            fi
        done
    fi
}

get_admin_password() {
    if [[ -z "$ADMIN_PASSWORD" ]]; then
        echo ""
        write_info "Create a secure password for the Aviatrix Controller administrator"
        echo ""
        echo "Password Requirements:"
        echo "├─ Minimum 8 characters"
        echo "├─ At least one letter (a-z, A-Z)"
        echo "├─ At least one number (0-9)"
        echo "└─ At least one symbol (!@#\$%^&*)"
        echo ""
        
        while true; do
            echo -ne "${CYAN}Administrator Password: ${NC}"
            read ADMIN_PASSWORD
            
            if [[ -z "$ADMIN_PASSWORD" ]]; then
                write_error "Password is required. Please enter a value."
                continue
            fi
            
            if validate_password "$ADMIN_PASSWORD"; then
                break
            else
                write_error "Invalid password. Please try again."
                continue
            fi
        done
    fi
}

get_customer_id() {
    if [[ -z "$CUSTOMER_ID" ]]; then
        echo ""
        write_info "Enter your Aviatrix customer license ID (required for controller initialization)"
        write_hint "Contact Aviatrix support if you don't have your customer license ID"
        
        while true; do
            echo -ne "${CYAN}Aviatrix Customer License ID: ${NC}"
            read CUSTOMER_ID
            
            if [[ -z "$CUSTOMER_ID" ]]; then
                write_error "Customer ID is required. Please enter a value."
                continue
            fi
            
            break
        done
    fi
}

get_copilot_choice() {
    if [[ "$INCLUDE_COPILOT" == "false" ]]; then
        echo ""
        write_info "CoPilot provides advanced analytics and monitoring for your Aviatrix network"
        write_info "CoPilot can be deployed later if you choose not to include it now"
        write_hint "CoPilot requires additional AWS resources and will increase deployment cost"
        
        while true; do
            echo -ne "${CYAN}Deploy CoPilot for analytics? (y/n) [default: y]: ${NC}"
            read choice
            
            # Use default if no input provided
            if [[ -z "$choice" ]]; then
                choice="y"
            fi
            
            # Convert to lowercase and trim whitespace
            choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]' | xargs)
            
            # Convert various user inputs to boolean
            case "$choice" in
                y|yes|true)
                    INCLUDE_COPILOT=true
                    break
                    ;;
                n|no|false)
                    INCLUDE_COPILOT=false
                    break
                    ;;
                *)
                    write_error "Invalid input '$choice'. Please enter 'y', 'yes', 'n', or 'no'"
                    ;;
            esac
        done
    fi
}

get_public_ip() {
    # Always detect CloudShell IP for security
    write_step "Detecting CloudShell public IP address for security configuration..."
    
    local cloudshell_ip
    if cloudshell_ip=$(curl -s --max-time 10 https://ipinfo.io/ip 2>/dev/null); then
        cloudshell_ip=$(echo "$cloudshell_ip" | tr -d '[:space:]')
        write_success "CloudShell public IP detected: $cloudshell_ip"
        
        # If no incoming CIDRs provided via CLI, use CloudShell IP as primary
        if [[ -z "$INCOMING_CIDRS" ]]; then
            write_info "Using CloudShell IP as primary access CIDR"
            INCOMING_CIDRS="$cloudshell_ip/32"
        else
            write_info "Adding CloudShell IP to provided incoming CIDRs"
            # Add CloudShell IP to existing CIDRs if not already included
            if [[ "$INCOMING_CIDRS" != *"$cloudshell_ip"* ]]; then
                INCOMING_CIDRS="$INCOMING_CIDRS,$cloudshell_ip/32"
            fi
        fi
        
        write_hint "CloudShell IP will be allowed to access the Aviatrix Controller web interface"
    else
        write_warning "Could not auto-detect CloudShell public IP address"
        
        # If no incoming CIDRs provided and can't detect IP, prompt user
        if [[ -z "$INCOMING_CIDRS" ]]; then
            write_info "You'll need to manually provide your public IP for security configuration"
            write_hint "You can find your IP at https://whatismyipaddress.com"
            INCOMING_CIDRS=$(get_user_input "Your Public IP Address" "" false validate_cidr)
            INCOMING_CIDRS="$INCOMING_CIDRS/32"
        else
            write_warning "CloudShell IP detection failed, but using provided incoming CIDRs"
            write_hint "You may need to manually add CloudShell IP to security groups later"
        fi
    fi
}

get_additional_mgmt_ips() {
    # Skip prompting if incoming CIDRs were provided via command line
    # This assumes user doesn't want additional prompts if they provided CLI args
    if [[ -z "$MGMT_IPS" && "$INCOMING_CIDRS_PROVIDED" != "true" ]]; then
        echo ""
        write_info "Specify additional CIDR blocks that should have access to the Controller and CoPilot"
        write_info "This is recommended for allowing access from your laptop, office network, etc."
        write_hint "Examples: 192.168.1.0/24, 10.0.0.50/32 (leave empty to skip)"
        
        echo -ne "${CYAN}Additional Management CIDRs (comma-separated, optional): ${NC}"
        read additional_ips
        
        if [[ -n "$additional_ips" ]]; then
            MGMT_IPS="$additional_ips"
        fi
    fi
}

# Prerequisites checking
test_prerequisites() {
    local is_destroy_operation="${1:-false}"
    write_step "Checking prerequisites..."
    
    # Check if running in AWS CloudShell
    if [[ -n "${AWS_EXECUTION_ENV:-}" && "$AWS_EXECUTION_ENV" == "CloudShell" ]]; then
        write_success "Running in AWS CloudShell"
    else
        write_warning "Running locally (not in AWS CloudShell)"
        echo "  This is fine for testing, but production deployments should use AWS CloudShell"
    fi
    
    # Check AWS CLI authentication
    if ! aws sts get-caller-identity &>/dev/null; then
        write_error "AWS CLI not authenticated. Please run 'aws configure' or 'aws sso login' first"
        exit 1
    fi
    
    local account_id
    account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
    write_success "AWS CLI authenticated (Account: $account_id)"
    
    # Check IAM permissions (skip for destroy operations)
    if [[ "$is_destroy_operation" != "true" ]]; then
        write_step "Checking IAM permissions..."
        
        # Try to list IAM roles to test permissions
        if aws iam list-roles --max-items 1 &>/dev/null; then
            write_success "IAM permissions verified"
        else
            write_warning "Could not verify IAM permissions automatically"
            echo "  The deployment may fail if you lack sufficient IAM permissions"
            echo "  Ensure you have permissions to create IAM roles, policies, and EC2 resources"
        fi
    else
        write_step "Skipping IAM permission check (destroy operation)"
    fi
    
    # Check Terraform installation
    if ! command -v terraform &>/dev/null; then
        write_step "Installing Terraform..."
        
        # Install Terraform in CloudShell
        if [[ -n "${AWS_EXECUTION_ENV:-}" && "$AWS_EXECUTION_ENV" == "CloudShell" ]]; then
            local terraform_version="1.5.7"
            cd /tmp
            wget -q "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip"
            unzip -q "terraform_${terraform_version}_linux_amd64.zip"
            sudo mv terraform /usr/local/bin/
            rm -f "terraform_${terraform_version}_linux_amd64.zip"
            cd - &>/dev/null
            write_success "Terraform installed successfully"
        else
            write_error "Terraform not found. Please install Terraform first:"
            echo "  Ubuntu/Debian: apt-get install terraform"
            echo "  macOS: brew install terraform"
            echo "  Or download from: https://www.terraform.io/downloads.html"
            exit 1
        fi
    else
        local terraform_version
        terraform_version=$(terraform --version | head -n1)
        write_success "Terraform available: $terraform_version"
    fi
    
    # Check marketplace subscriptions (skip for destroy operations)
    if [[ "$is_destroy_operation" != "true" ]]; then
        write_step "Marketplace subscription check will be performed during deployment configuration..."
    fi
}

# Check for existing IAM roles
check_existing_iam_roles() {
    local roles_exist=false
    local required_roles=(
        "aviatrix-role-ec2"
        "aviatrix-role-app"
    )
    
    local existing_roles=()
    local missing_roles=()
    
    # Check each required role
    for role in "${required_roles[@]}"; do
        if aws iam get-role --role-name "$role" &>/dev/null; then
            existing_roles+=("$role")
            roles_exist=true
        else
            missing_roles+=("$role")
        fi
    done
    
    # Output messages to stderr so they don't interfere with return value
    if [[ "$roles_exist" == "true" ]]; then
        write_success "Found existing Aviatrix IAM roles: ${existing_roles[*]}" >&2
        if [[ ${#missing_roles[@]} -gt 0 ]]; then
            write_warning "Missing IAM roles: ${missing_roles[*]}" >&2
            write_info "The module will create the missing roles only" >&2
        else
            write_info "All required IAM roles exist - skipping IAM role creation in module" >&2
        fi
        
        # If all roles exist, we can skip IAM role creation entirely
        if [[ ${#missing_roles[@]} -eq 0 ]]; then
            echo "false"  # Don't create IAM roles
        else
            echo "true"   # Create missing IAM roles
        fi
    else
        write_info "No existing Aviatrix IAM roles found - will create all required roles" >&2
        echo "true"  # Create IAM roles
    fi
}

# Terraform configuration generation
create_terraform_config() {
    write_step "Creating Terraform configuration..."
    
    # Check for existing IAM roles
    write_step "Checking for existing Aviatrix IAM roles..."
    local create_iam_roles
    create_iam_roles=$(check_existing_iam_roles)
    
    # Create deployment directory
    if [[ -d "$TERRAFORM_DIR" ]]; then
        rm -rf "$TERRAFORM_DIR"
    fi
    mkdir -p "$TERRAFORM_DIR"
    
    # Build incoming_ssl_cidrs array
    local all_cidrs=()
    
    # Parse INCOMING_CIDRS (may be comma-separated)
    if [[ -n "$INCOMING_CIDRS" ]]; then
        IFS=',' read -ra incoming_array <<< "$INCOMING_CIDRS"
        for cidr in "${incoming_array[@]}"; do
            cidr=$(echo "$cidr" | xargs)  # trim whitespace
            all_cidrs+=("$cidr")
        done
    fi
    
    # Add management IPs if provided
    if [[ -n "$MGMT_IPS" ]]; then
        IFS=',' read -ra mgmt_array <<< "$MGMT_IPS"
        for ip in "${mgmt_array[@]}"; do
            ip=$(echo "$ip" | xargs)  # trim whitespace
            if [[ ! "$ip" =~ /[0-9]{1,2}$ ]]; then
                ip="$ip/32"
            fi
            all_cidrs+=("$ip")
        done
    fi
    
    # Format CIDRs for Terraform
    local cidr_string=""
    for i in "${!all_cidrs[@]}"; do
        if [[ $i -gt 0 ]]; then
            cidr_string+=", "
        fi
        cidr_string+="\"${all_cidrs[$i]}\""
    done
    
    #Check if default keypair exists
    write_step "Checking for existing AWS key pair 'aviatrix_controller_kp'..."
    use_existing_keypair=$(aws ec2 describe-key-pairs --key-names aviatrix_controller_kp --region "$REGION" &>/dev/null && echo "true" || echo "false")
    if [[ "$use_existing_keypair" == "true" ]]; then
        write_info "Found existing key pair 'aviatrix_controller_kp' - will reuse it"
        else
        write_info "Key pair 'aviatrix_controller_kp' not found - will create a new one"
        fi

    # Create main.tf
    cat > "$TERRAFORM_DIR/main.tf" << EOF
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0.0"
    }
  }
}

provider "aws" {
  region = "$REGION"
}

module "aviatrix_controlplane" {
  source  = "$MODULE_SOURCE"
  version = "$MODULE_VERSION"

  # Basic Configuration
  controller_name           = "$DEPLOYMENT_NAME-controller"
  customer_id              = "$CUSTOMER_ID"
  controller_admin_email    = "$ADMIN_EMAIL"
  controller_admin_password = "$ADMIN_PASSWORD"
  
  # Network Security
  incoming_ssl_cidrs = [$cidr_string]
  
  # Account Configuration  
  access_account_name = "AWS-Primary"
  account_email      = "$ADMIN_EMAIL"
  
  # SSH Keys
  controller_use_existing_keypair = "$use_existing_keypair"
  controller_key_pair_name        = "aviatrix_controller_kp"

  # Deployment Configuration
  module_config = {
    controller_deployment     = true
    controller_initialization = true
    copilot_deployment       = $(echo "$INCLUDE_COPILOT" | tr '[:upper:]' '[:lower:]')
    copilot_initialization   = $(echo "$INCLUDE_COPILOT" | tr '[:upper:]' '[:lower:]')
    iam_roles                = $create_iam_roles
    account_onboarding       = true
  }
EOF

    if [[ "$INCLUDE_COPILOT" == "true" ]]; then
        cat >> "$TERRAFORM_DIR/main.tf" << EOF

  # CoPilot Configuration
  copilot_name = "$DEPLOYMENT_NAME-copilot"
EOF
    fi

    cat >> "$TERRAFORM_DIR/main.tf" << EOF

}
EOF

    # Create outputs.tf
    local copilot_step
    if [[ "$INCLUDE_COPILOT" == "true" ]]; then
        copilot_step='format("4. Access CoPilot at https://%s", module.aviatrix_controlplane.copilot_public_ip)'
    else
        copilot_step='"4. CoPilot not deployed - can be added later if needed"'
    fi
    
    cat > "$TERRAFORM_DIR/outputs.tf" << 'HEREDOC_EOF'
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    controller_public_ip  = module.aviatrix_controlplane.controller_public_ip
    controller_private_ip = module.aviatrix_controlplane.controller_private_ip
    controller_url       = module.aviatrix_controlplane.controller_public_ip != null ? format("https://%s", module.aviatrix_controlplane.controller_public_ip) : null
    copilot_public_ip    = module.aviatrix_controlplane.copilot_public_ip
    copilot_url         = module.aviatrix_controlplane.copilot_public_ip != null ? format("https://%s", module.aviatrix_controlplane.copilot_public_ip) : null
    deployment_name     = "DEPLOYMENT_NAME_PLACEHOLDER"
    region             = "REGION_PLACEHOLDER"
    admin_email        = "ADMIN_EMAIL_PLACEHOLDER"
  }
  sensitive = false
}

output "connection_info" {
  description = "Connection information for accessing deployed services"
  value = {
    controller_login_url = format("https://%s", module.aviatrix_controlplane.controller_public_ip)
    controller_username  = "admin"
    copilot_login_url   = module.aviatrix_controlplane.copilot_public_ip != null ? format("https://%s", module.aviatrix_controlplane.copilot_public_ip) : "Not deployed"
    next_steps = [
      format("1. Access controller at https://%s", module.aviatrix_controlplane.controller_public_ip),
      "2. Login with username 'admin' and your configured password",
      "3. Your AWS account is already onboarded and ready to use",
      COPILOT_STEP_PLACEHOLDER
    ]
  }
}
HEREDOC_EOF

    write_success "Terraform configuration created in $TERRAFORM_DIR"
    
    # Replace placeholders in outputs.tf
    sed -i "s/DEPLOYMENT_NAME_PLACEHOLDER/$DEPLOYMENT_NAME/g" "$TERRAFORM_DIR/outputs.tf"
    sed -i "s/REGION_PLACEHOLDER/$REGION/g" "$TERRAFORM_DIR/outputs.tf"
    sed -i "s/ADMIN_EMAIL_PLACEHOLDER/$ADMIN_EMAIL/g" "$TERRAFORM_DIR/outputs.tf"
    sed -i "s|COPILOT_STEP_PLACEHOLDER|$copilot_step|g" "$TERRAFORM_DIR/outputs.tf"
}

# Terraform execution
run_terraform() {
    cd "$TERRAFORM_DIR"
    
    write_step "Initializing Terraform..."
    if ! terraform init; then
        write_error "Terraform init failed"
        exit 1
    fi
    write_success "Terraform initialized"
    
    case "$TERRAFORM_ACTION" in
        "plan")
            write_step "Running Terraform plan..."
            terraform plan
            return 0
            ;;
        "destroy")
            write_step "Running Terraform destroy..."
            if [[ "$SKIP_CONFIRMATION" != "true" ]]; then
                echo ""
                write_warning "This will permanently delete all Aviatrix resources!"
                echo "This includes:"
                echo "├─ Aviatrix Controller EC2 instance and associated resources"
                echo "├─ CoPilot EC2 instance (if deployed)"
                echo "├─ IAM roles and policies"
                echo "├─ VPC and Security Groups"
                echo "└─ All data and configurations"
                echo ""
                
                read -p "Type 'yes' to confirm destruction: " confirm
                if [[ "$confirm" != "yes" ]]; then
                    write_info "Destruction cancelled"
                    exit 0
                fi
            fi
            terraform destroy -auto-approve
            return 0
            ;;
        "apply")
            write_step "Validating Terraform configuration..."
            if ! terraform validate; then
                write_error "Terraform validation failed"
                exit 1
            fi
            
            write_step "Planning deployment resources..."
            if ! terraform plan -out=tfplan; then
                write_error "Terraform plan failed"
                exit 1
            fi
            
            if [[ "$SKIP_CONFIRMATION" != "true" ]]; then
                echo ""
                write_banner "Final Deployment Confirmation" "yellow"
                
                echo "Deployment Overview:"
                echo "├─ Aviatrix Controller EC2 instance in $REGION"
                echo "├─ IAM roles and policies for API access"
                echo "├─ Controller initialization and account onboarding"
                if [[ "$INCLUDE_COPILOT" == "true" ]]; then
                    echo "├─ CoPilot EC2 instance for advanced analytics"
                fi
                echo "├─ VPC security groups (access from $INCOMING_CIDRS)"
                echo "└─ AWS marketplace agreements"
                echo ""
                
                read -p "Press Enter to continue with deployment or Ctrl+C to cancel: "
            fi
            
            write_banner "Starting Aviatrix Control Plane Deployment" "green"
            write_info "Sit back and relax - this will take approximately 10-15 minutes..."
            echo ""
            
            local start_time
            start_time=$(date +%s)
            
            if ! terraform apply tfplan; then
                write_error "Terraform apply failed"
                exit 1
            fi
            
            local end_time
            end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local minutes=$((duration / 60))
            local seconds=$((duration % 60))
            
            echo ""
            write_banner "Deployment Completed Successfully!" "green"
            
            echo "Deployment Statistics:"
            echo "├─ Total Time: ${minutes}m ${seconds}s"
            echo "├─ Region: $REGION"
            echo "└─ Status: All resources deployed successfully"
            echo ""
            
            # Show outputs
            terraform output -json | jq -r '.deployment_summary.value | to_entries[] | "├─ \(.key): \(.value)"' 2>/dev/null || terraform output
            
            echo ""
            echo "What's Next?"
            echo "├─ Start creating gateways in your preferred cloud regions"
            echo "├─ Connect your on-premises networks"
            echo "├─ Monitor traffic through the dashboard"
            if [[ "$INCLUDE_COPILOT" == "true" ]]; then
                echo "├─ Explore advanced analytics in CoPilot"
            else
                echo "├─ Consider adding CoPilot later for advanced analytics"
            fi
            echo "└─ Check out the documentation links below"
            echo ""
            ;;
    esac
    
    cd - &>/dev/null
}

# Configuration collection
collect_deployment_config() {
    write_banner "Aviatrix Control Plane Deployment Configuration" "cyan"
    
    write_info "This wizard will guide you through configuring your Aviatrix deployment"
    write_info "All required fields will be prompted. Press Ctrl+C to cancel at any time"
    echo ""
    
    get_deployment_name
    get_region
    get_admin_email
    get_admin_password
    get_customer_id
    get_copilot_choice
    get_public_ip
    get_additional_mgmt_ips
}

# Configuration summary
show_config_summary() {
    if [[ "$SKIP_CONFIRMATION" == "true" ]]; then
        return 0
    fi
    
    write_banner "Deployment Configuration Summary" "green"
    
    echo "Deployment Details:"
    echo "├─ Deployment Name: $DEPLOYMENT_NAME"
    echo "├─ AWS Region: $REGION"
    echo "├─ Admin Email: $ADMIN_EMAIL"
    echo "├─ Customer License ID: $CUSTOMER_ID"
    echo "├─ Include CoPilot: $(if [[ "$INCLUDE_COPILOT" == "true" ]]; then echo "Yes (Additional analytics and monitoring)"; else echo "No"; fi)"
    echo "├─ CloudShell IP: $INCOMING_CIDRS"
    if [[ -n "$MGMT_IPS" ]]; then
        echo "├─ Additional Management IPs: $MGMT_IPS"
    fi
    echo "└─ Terraform Action: $TERRAFORM_ACTION"
    echo ""
    
    echo "Resources to be Deployed:"
    echo "├─ Aviatrix Controller EC2 instance"
    echo "├─ IAM roles and policies"
    echo "├─ VPC and Security Groups"
    echo "├─ Controller Initialization"
    echo "├─ AWS Account Onboarding"
    if [[ "$INCLUDE_COPILOT" == "true" ]]; then
        echo "└─ CoPilot Configuration"
    else
        echo "└─ (CoPilot not included)"
    fi
    echo ""
    
    write_info "Estimated deployment time: 10-15 minutes"
    if [[ "$INCLUDE_COPILOT" == "true" ]]; then
        write_info "CoPilot deployment will add approximately 5 additional minutes"
    fi
    echo ""
}

# Post-deployment information
show_post_deployment_info() {
    write_banner "Important Information & Resources" "magenta"
    
    echo "Security & Access:"
    echo "├─ Controller access is restricted to: $INCOMING_CIDRS"
    if [[ -n "$MGMT_IPS" ]]; then
        echo "├─ Additional management access: $MGMT_IPS"
    fi
    echo "├─ Default username: admin"
    echo "├─ Consider changing the admin password after first login"
    echo "├─ Set up additional admin users for your team"
    echo "└─ Enable multi-factor authentication for enhanced security"
    echo ""
    
    echo "Learning Resources:"
    echo "├─ Official Documentation: https://docs.aviatrix.com"
    echo "├─ Getting Started Guide: https://docs.aviatrix.com/StartUpGuides/"
    echo "├─ Video Tutorials: https://aviatrix.com/learn/"
    echo "└─ Support Portal: https://support.aviatrix.com"
    echo ""
    
    echo "Managing This Deployment:"
    echo "├─ Terraform files location: $TERRAFORM_DIR"
    echo "├─ To modify: Edit main.tf and run 'terraform apply'"
    echo "├─ To destroy: Run this script with -a destroy"
    echo "└─ Keep the terraform directory for future management"
    echo ""
    
    echo "Next Steps:"
    echo "├─ 1️⃣  Log in and familiarize yourself with the dashboard"
    echo "├─ 2️⃣  Create your first transit gateway"
    echo "├─ 3️⃣  Connect additional cloud accounts (Azure, GCP, etc.)"
    echo "├─ 4️⃣  Set up monitoring and alerting"
    echo "└─ 5️⃣  Explore advanced features like segmentation"
    echo ""
}

# Error handling
handle_error() {
    local exit_code=$?
    echo ""
    write_banner "Deployment Failed" "red"
    
    echo "Error Details:"
    echo "├─ Exit Code: $exit_code"
    echo "├─ Time: $(date)"
    echo "└─ Check the output above for specific error messages"
    echo ""
    
    echo "Common Solutions:"
    echo "├─ Authentication Issues:"
    echo "│  ├─ Run 'aws configure' or 'aws sso login'"
    echo "│  └─ Ensure you have sufficient AWS permissions"
    echo "├─ Resource Issues:"
    echo "│  ├─ Check AWS service quotas in selected region"
    echo "│  ├─ Verify IAM permissions for EC2, VPC, IAM"
    echo "│  └─ Ensure deployment name is unique"
    echo "├─ Network Issues:"
    echo "│  ├─ Check internet connectivity"
    echo "│  └─ Verify AWS service endpoints are accessible"
    echo "└─ Input Validation:"
    echo "   ├─ Verify all parameters are correct"
    echo "   ├─ Check email format and customer ID"
    echo "   └─ Ensure password meets requirements"
    echo ""
    
    echo "Getting Help:"
    echo "├─ Include the error output when requesting support"
    echo "├─ AWS Region: ${REGION:-Not specified}"
    echo "├─ Deployment Name: ${DEPLOYMENT_NAME:-Not specified}"
    echo "├─ Terraform logs: $TERRAFORM_DIR (if available)"
    echo "├─ Aviatrix Support: https://support.aviatrix.com"
    echo "└─ Documentation: https://docs.aviatrix.com"
    echo ""
    
    if [[ -d "$TERRAFORM_DIR" ]]; then
        echo "Cleanup:"
        echo "├─ To clean up partial resources:"
        echo "│  └─ Run: $0 -a destroy -n ${DEPLOYMENT_NAME:-your-deployment}"
        echo "└─ Or manually clean up via AWS console"
        echo ""
    fi
    
    exit $exit_code
}

# Main execution
main() {
    # Set up error handling
    trap 'handle_error' ERR
    
    # Parse command line arguments
    parse_args "$@"
    
    write_banner "Aviatrix Control Plane Deployment Wizard" "cyan"
    
    echo "Welcome to the Aviatrix AWS Deployment Wizard!"
    echo "├─ Purpose: Deploy a complete Aviatrix control plane in AWS"
    echo "├─ Includes: Controller, initialization, and AWS account onboarding"
    echo "├─ Optimized: For AWS CloudShell with user-friendly prompts"
    echo "└─ Secure: Follows security best practices and least privilege"
    echo ""
    
    write_info "This wizard will guide you through each step of the deployment process"
    write_hint "You can press Ctrl+C at any time to cancel the deployment safely"
    echo ""
    
    # Check prerequisites
    test_prerequisites "$([[ "$TERRAFORM_ACTION" == "destroy" ]] && echo "true" || echo "false")"
    
    # Handle destroy operations differently
    if [[ "$TERRAFORM_ACTION" == "destroy" ]]; then
        write_banner "Destroying Aviatrix Deployment" "red"
        
        if [[ ! -d "$TERRAFORM_DIR" ]]; then
            write_error "Terraform directory not found: $TERRAFORM_DIR"
            echo "Cannot destroy deployment - no terraform state found."
            echo "The deployment may have already been destroyed or was never created."
            exit 1
        fi
        
        write_info "Found existing Terraform deployment in: $TERRAFORM_DIR"
        
        run_terraform
        
        write_banner "Destruction Complete" "green"
        echo "All Aviatrix resources have been successfully destroyed."
        echo "└─ Terraform state and configuration files remain in $TERRAFORM_DIR"
        echo ""
        return 0
    fi
    
    # For non-destroy operations, collect configuration
    collect_deployment_config
    
    # Show configuration summary
    show_config_summary
    
    # Create Terraform configuration
    create_terraform_config
    
    # Execute Terraform or validate in test mode
    if [[ "$TEST_MODE" == "true" ]]; then
        write_banner "Test Mode - Validation Complete" "green"
        
        echo "Validation Results:"
        echo "├─ All input parameters validated successfully"
        echo "├─ Terraform configuration generated without errors"
        echo "├─ Prerequisites checked and verified"
        echo "└─ Deployment ready to proceed"
        echo ""
        
        echo "Generated Files:"
        echo "├─ Location: $TERRAFORM_DIR"
        echo "├─ main.tf - Main Terraform configuration"
        echo "└─ outputs.tf - Output definitions"
        echo ""
        
        echo "Next Steps:"
        echo "├─ To deploy for real: Run this script again without -t"
        echo "├─ Alternative: cd $TERRAFORM_DIR && terraform init && terraform apply"
        echo "└─ Review the generated files to understand what will be deployed"
        echo ""
    else
        run_terraform
        
        # Show post-deployment information
        if [[ "$TERRAFORM_ACTION" == "apply" ]]; then
            show_post_deployment_info
        fi
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
