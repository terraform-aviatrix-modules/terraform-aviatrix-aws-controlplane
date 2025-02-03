variable "availability_zone" {
  type        = string
  description = "Availability zone"
  default     = ""
  nullable    = false
}

variable "vpc_cidr" {
  type        = string
  description = "VPC in which you want launch Aviatrix controller"
  default     = "10.0.0.0/16"
  nullable    = false
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet in which you want launch Aviatrix controller"
  default     = "10.0.1.0/24"
  nullable    = false
}

variable "use_existing_vpc" {
  type        = bool
  description = "Flag to indicate whether to use an existing VPC"
  default     = false
  nullable    = false
}

variable "vpc_id" {
  type        = string
  description = "VPC ID, required when use_existing_vpc is true"
  default     = ""
  nullable    = false
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID, only required when use_existing_vpc is true"
  default     = ""
  nullable    = false
}

variable "use_existing_keypair" {
  type        = bool
  default     = false
  description = "Flag to indicate whether to use an existing key pair"
}

variable "key_pair_name" {
  type        = string
  description = "Key pair name"
  default     = ""
  nullable    = false
}

variable "ec2_role_name" {
  type        = string
  description = "EC2 role for controller"
  default     = ""
  nullable    = false
}

variable "tags" {
  type        = map(string)
  description = "Map of common tags which should be used for module resources"
  default     = {}
  nullable    = false
}

variable "termination_protection" {
  type        = bool
  description = "Enable/disable switch for termination protection"
  default     = true
  nullable    = false
}

variable "incoming_ssl_cidrs" {
  type        = list(string)
  description = "Incoming cidr for security group used by controller"
}

variable "root_volume_size" {
  type        = number
  description = "Root volume disk size for controller"
  default     = 64
  nullable    = false
}

variable "root_volume_type" {
  type        = string
  description = "Root volume type for controller"
  default     = "gp3"
  nullable    = false
}

variable "instance_type" {
  type        = string
  description = "Controller instance size"
  default     = "t3.large"
  nullable    = false
}

variable "name_prefix" {
  type        = string
  description = "Additional name prefix for your environment resources"
  default     = ""
  nullable    = false
}

variable "ami_id" {
  type        = string
  description = "AMI ID for controller. If unset, use official image."
  default     = ""
  nullable    = false
}

variable "user_data" {
  type        = string
  description = "User data for starting the controller"
  default     = ""
  nullable    = false
}

variable "controller_name" {
  type        = string
  description = "Name of controller that will be launched. If not set, default name will be used."
  default     = ""
  nullable    = false
}

variable "controller_version" {
  type        = string
  description = "Aviatrix Controller version"
  default     = "latest"
}

variable "root_volume_encrypted" {
  type        = bool
  description = "Whether the root volume is encrypted"
  default     = true
  nullable    = false
}

variable "root_volume_kms_key_id" {
  type        = string
  description = "ARN for the key used to encrypt the root volume"
  default     = ""
  nullable    = false
}

data "aws_region" "current" {}

data "aws_availability_zones" "all" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ec2_instance_type_offering" "offering" {
  for_each = toset(data.aws_availability_zones.all.names)

  filter {
    name   = "instance-type"
    values = ["t2.micro", "t3.micro", var.instance_type]
  }

  filter {
    name   = "location"
    values = [each.value]
  }

  location_type = "availability-zone"

  preferred_instance_types = [var.instance_type, "t3.micro", "t2.micro"]
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
  type    = map(any)
  default = {}
}

locals {
  name_prefix       = var.name_prefix != "" ? "${var.name_prefix}_" : ""
  controller_name   = var.controller_name != "" ? var.controller_name : "${local.name_prefix}AviatrixController"
  key_pair_name     = var.key_pair_name != "" ? var.key_pair_name : "aviatrix_controller_kp"
  ec2_role_name     = var.ec2_role_name != "" ? var.ec2_role_name : "aviatrix-role-ec2"
  is_aws_cn         = element(split("-", data.aws_region.current.name), 0) == "cn" ? true : false
  images            = jsondecode(data.http.avx_ami_id.response_body)["g4"]["amd64"]
  ami_id            = var.ami_id != "" ? var.ami_id : local.images[data.aws_region.current.name]
  default_az        = keys({ for az, details in data.aws_ec2_instance_type_offering.offering : az => details.instance_type if details.instance_type == var.instance_type })[0]
  availability_zone = var.availability_zone != "" ? var.availability_zone : local.default_az

  common_tags = merge(
    var.tags, {
      module    = "aviatrix-controller-build"
      Createdby = "Terraform+Aviatrix"
  })

  cloud_init = base64encode(templatefile("${path.module}/cloud-init.tftpl", {
    controller_version        = var.controller_version
    environment               = var.environment
    registry_auth_token       = var.registry_auth_token
    additional_bootstrap_args = length(var.additional_bootstrap_args) > 0 ? yamlencode(var.additional_bootstrap_args) : ""
  }))
}

data "http" "avx_ami_id" {
  url = format("https://cdn.%s.sre.aviatrix.com/image-details/aws_controller_image_details.json", var.environment)

  request_headers = {
    "Accept" = "application/json"
  }
}
