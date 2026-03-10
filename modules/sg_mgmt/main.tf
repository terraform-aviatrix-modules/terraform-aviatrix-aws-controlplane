data "aws_region" "current" {}

data "http" "ctrl_login" {
  url      = "https://${var.controller_public_ip}/v2/api"
  method   = "POST"
  insecure = true

  request_headers = {
    Content-Type = "application/json"
  }

  request_body = jsonencode({
    action   = "login"
    username = var.controller_admin_username
    password = var.controller_admin_password
  })
}

locals {
  current_cid = jsondecode(data.http.ctrl_login.response_body)["CID"]
  region      = data.aws_region.current.name
}

resource "terracurl_request" "security_group_management" {
  name = "security_group_management"
  # Dummy URL during apply phase
  url            = var.dummy_url
  method         = "GET"
  response_codes = [200]

  # Destroy Phase Configuration
  destroy_url             = "https://${var.controller_public_ip}/v2/api"
  destroy_method          = "POST"
  destroy_skip_tls_verify = true
  destroy_timeout         = 300
  destroy_request_body = jsonencode({
    action = "disable_controller_security_group_management",
    CID    = local.current_cid
  })

  destroy_headers = {
    Content-Type = "application/json"
  }
}

resource "terracurl_request" "copilot_security_group_management" {
  count = var.enable_copilot_security_group_management ? 1 : 0
  name  = "copilot_sg"

  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  response_codes  = [200]
  skip_tls_verify = true
  timeout         = 300
  request_body = jsonencode({
    action       = "enable_copilot_sg",
    CID          = local.current_cid,
    cloud_type   = 1,
    account_name = var.access_account_name
    vpc_id       = var.vpc_id,
    instance_id  = var.instance_id,
    region       = local.region
  })
  headers = {
    Content-Type = "application/json"
  }

  # Destroy Phase Configuration
  destroy_url             = "https://${var.controller_public_ip}/v2/api"
  destroy_method          = "POST"
  destroy_skip_tls_verify = true
  destroy_timeout         = 300
  destroy_request_body = jsonencode({
    action       = "disable_copilot_sg",
    CID          = local.current_cid
    cloud_type   = 1,
    account_name = var.access_account_name,
    vpc_id       = var.vpc_id,
    instance_id  = var.instance_id,
    region       = local.region
  })

  destroy_headers = {
    Content-Type = "application/json"
  }
}
