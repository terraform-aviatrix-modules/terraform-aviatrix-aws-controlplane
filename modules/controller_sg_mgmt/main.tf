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