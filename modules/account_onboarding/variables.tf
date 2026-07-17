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
  default     = "AWS"
}

variable "account_email" {
  type        = string
  description = "Account email address"
}

variable "aws_role_ec2" {
  type     = string
  default  = "aviatrix-role-ec2"
  nullable = false
}

variable "aws_role_app" {
  type     = string
  default  = "aviatrix-role-app"
  nullable = false
}

variable "cloud_type" {
  type        = number
  description = "Aviatrix cloud type of the access account (1 = AWS Commercial, 256 = AWS GovCloud, 1024 = AWS China)."
  default     = 1
  nullable    = false

  validation {
    condition     = contains([1, 256, 1024], var.cloud_type)
    error_message = "cloud_type must be one of 1 (AWS), 256 (AWS GovCloud), or 1024 (AWS China)."
  }
}

# terraform-docs-ignore
variable "destroy_url" {
  type        = string
  description = "Dummy URL used by terracurl during destroy operations."
  default     = "https://checkip.amazonaws.com"
}
