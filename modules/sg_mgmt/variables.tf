variable "controller_public_ip" {
  type        = string
  description = "aviatrix controller public ip address(required)"
}

variable "controller_admin_username" {
  type        = string
  default     = "admin"
  description = "aviatrix controller admin username"
  nullable    = false
}

variable "controller_admin_password" {
  type        = string
  sensitive   = true
  description = "aviatrix controller admin password"
  nullable    = false
}

variable "dummy_url" {
  type        = string
  description = "Dummy URL used by terracurl during apply operations."
  default     = "https://checkip.amazonaws.com"
  nullable    = false
}

variable "access_account_name" {
  type        = string
  description = "Aviatrix access account name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the copilot instance is deployed."
}

variable "instance_id" {
  type        = string
  description = "EC2 instance ID for the Aviatrix Copilot instance."
  nullable    = false
}

variable "enable_copilot_security_group_management" {
  type        = bool
  description = "Enable Copilot security group management"
  default     = true
  nullable    = false
}
