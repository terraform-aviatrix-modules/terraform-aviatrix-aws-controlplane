variable "name_prefix" {
  type        = string
  description = "Name prefix for your EC2 role name and APP role name"
  default     = ""
}

variable "ec2_role_name" {
  type        = string
  description = "EC2 role name"
  default     = ""
  nullable    = false
}

variable "app_role_name" {
  type        = string
  description = "APP role name"
  default     = ""
  nullable    = false
}

variable "app_role_max_session_duration" {
  type        = number
  description = "Maximum session duration (in seconds) for the Aviatrix APP role"
  default     = 3600
  nullable    = false

  validation {
    condition     = var.app_role_max_session_duration >= 3600 && var.app_role_max_session_duration <= 43200
    error_message = "app_role_max_session_duration must be between 3600 and 43200 seconds."
  }
}

variable "external_controller_account_id" {
  type    = string
  default = ""
}

variable "secondary_account_ids" {
  type    = list(string)
  default = []
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  name_prefix          = var.name_prefix != "" ? "${var.name_prefix}-" : ""
  ec2_role_name        = var.ec2_role_name != "" ? var.ec2_role_name : "${local.name_prefix}aviatrix-role-ec2"
  app_role_name        = var.app_role_name != "" ? var.app_role_name : "${local.name_prefix}aviatrix-role-app"
  arn_partition        = element(split("-", data.aws_region.current.region), 0) == "cn" ? "aws-cn" : (element(split("-", data.aws_region.current.region), 1) == "gov" ? "aws-us-gov" : "aws")
  is_aws_cn            = element(split("-", data.aws_region.current.region), 0) == "cn" ? ".cn" : ""
  other_account_id     = data.aws_caller_identity.current.account_id
  resource_account_ids = length(var.secondary_account_ids) == 0 ? [local.other_account_id] : concat(var.secondary_account_ids, [local.other_account_id])
  resource_strings = [
    for id in local.resource_account_ids :
    "arn:${local.arn_partition}:iam::${id}:role/${local.app_role_name}"
  ]

  identifiers = (var.external_controller_account_id == "" ?
    [
      "arn:${local.arn_partition}:iam::${local.other_account_id}:root",
    ]
    :
    [
      "arn:${local.arn_partition}:iam::${var.external_controller_account_id}:root",
      "arn:${local.arn_partition}:iam::${local.other_account_id}:root"
    ]
  )
}
