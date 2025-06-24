variable "access_account_name" {
  type        = string
  description = "aviatrix controller access account name"
}

variable "account_email" {
  type        = string
  description = "aviatrix controller access account email"
}

variable "customer_id" {
  type        = string
  description = "aviatrix customer license id"
}

variable "controller_admin_email" {
  type        = string
  description = "aviatrix controller admin email address"
}

variable "controller_admin_password" {
  type        = string
  description = "aviatrix controller admin password"
}

variable "copilot_service_account_password" {
  type     = string
  default  = ""
  nullable = false
}

variable "controller_name" {
  type        = string
  description = "Customized Name for Aviatrix Controller"
  default     = "Aviatrix-Controller"

  validation {
    condition     = can(regex("^[^\\\\/\"\\[\\]:|<>+=;,?*@&~!#$%^()_{}']*$", var.controller_name))
    error_message = "Input string cannot contain the following special characters: `\\` `/` `\"` `[` `]` `:` `|` `<` `>` `+` `=` `;` `,` `?` `*` `@` `&` `~` `!` `#` `$` `%` `^` `(` `)` `_` `{` `}` `'`"
  }
}

variable "controller_ec2_role_name" {
  type        = string
  description = "EC2 role for controller"
  default     = null
}

# terraform-docs-ignore
variable "controller_ami_id" {
  type        = string
  description = "AMI ID for controller. If unset, use official image."
  default     = ""
  nullable    = false
}

# terraform-docs-ignore
variable "copilot_ami_id" {
  type        = string
  description = "AMI ID for copilot. If unset, use official image."
  default     = ""
  nullable    = false
}

# terraform-docs-ignore
variable "controller_use_existing_keypair" {
  type        = bool
  default     = false
  description = "Flag to indicate whether to use an existing key pair"
}

# terraform-docs-ignore
variable "controller_key_pair_name" {
  type        = string
  description = "Key pair name"
  default     = ""
  nullable    = false
}

variable "copilot_name" {
  type        = string
  description = "Customized Name for Aviatrix Copilot"
  default     = "Aviatrix-Copilot"
}

# terraform-docs-ignore
variable "copilot_use_existing_keypair" {
  type        = bool
  default     = false
  description = "Flag to indicate whether to use an existing key pair"
}

# terraform-docs-ignore
variable "copilot_key_pair_name" {
  type        = string
  description = "Key pair name"
  default     = ""
  nullable    = false
}

variable "controlplane_subnet_cidr" {
  type        = string
  description = "CIDR for controlplane subnet."
  default     = "10.0.0.0/24"
}

variable "controlplane_vpc_cidr" {
  type        = string
  description = "CIDR for controller VPC."
  default     = "10.0.0.0/24"
}


variable "controller_version" {
  type        = string
  description = "Aviatrix Controller version"
  default     = "latest"
}

variable "incoming_ssl_cidrs" {
  type        = list(string)
  description = "Incoming cidrs for security group used by controller"
}

variable "use_existing_vpc" {
  type        = bool
  description = "Flag to indicate whether to use an existing VPC"
  default     = false
}

variable "vpc_id" {
  type        = string
  description = "VPC name, only required when use_existing_vpc is true"
  default     = ""
}

variable "subnet_name" {
  type        = string
  description = "subnet name, only required when use_existing_vpc is true."
  default     = ""
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID, only required when use_existing_vpc is true."
  default     = ""
}

variable "availability_zone" {
  description = "The Availability zone in which to deploy the controlplane."
  default     = ""
  type        = string
}

variable "controller_instance_type" {
  description = "The instance type used for deploying the controller."
  type        = string
  default     = "t3.large"
}

variable "copilot_instance_type" {
  type        = string
  description = "The instance type used for deploying copilot."
  default     = null
}

variable "module_config" {
  default = {
    controller_deployment     = true,
    controller_initialization = true,
    copilot_deployment        = true,
    copilot_initialization    = true,
    iam_roles                 = true,
    account_onboarding        = true,
  }
}

# terraform-docs-ignore
variable "environment" {
  description = "Determines the deployment environment. For internal use only."
  type        = string
  default     = "prod"
  nullable    = false

  validation {
    condition     = contains(["prod", "staging"], var.environment)
    error_message = "The environment must be either 'prod' or 'staging'."
  }
}

# terraform-docs-ignore
variable "registry_auth_token" {
  description = "The token used to authenticate to the controller artifact registry. For internal use only."
  type        = string
  default     = ""
  nullable    = false
}

# terraform-docs-ignore
variable "additional_bootstrap_args" {
  description = "Additional bootstrap arguments. For internal use only."
  type        = map(any)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name_prefix" {
  description = "Prefix to apply to all resources"
  type        = string
  default     = ""
}
