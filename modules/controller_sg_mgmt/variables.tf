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

variable "dummy_url" {
  type        = string
  description = "Dummy URL used by terracurl during apply operations."
  default     = "https://checkip.amazonaws.com"
}
