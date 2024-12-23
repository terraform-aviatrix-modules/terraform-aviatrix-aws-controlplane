variable "controller_public_ip" {
  type        = string
  description = "aviatrix controller public ip address(required)"
}

variable "controller_admin_username" {
  type        = string
  default     = "admin"
  description = "aviatrix controller admin username"
}

variable "controller_admin_password" {
  type        = string
  sensitive   = true
  description = "aviatrix controller admin password"
}

variable "access_account_name" {
  type        = string
  description = "Access account name"
  default     = "Azure"
}

variable "account_email" {
  type        = string
  description = "Account email address"
}

variable "arm_subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "arm_directory_id" {
  type        = string
  description = "Azure directory ID"
}

variable "arm_client_id" {
  type        = string
  description = "Azure client ID"
}

variable "arm_application_key" {
  type        = string
  sensitive   = true
  description = "Azure application key"
}
