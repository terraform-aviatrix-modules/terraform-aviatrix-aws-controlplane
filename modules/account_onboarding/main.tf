#Login, obtain CID.
data "http" "controller_login" {
  url      = "https://${var.controller_public_ip}/v2/api"
  insecure = true
  method   = "POST"
  request_headers = {
    "Content-Type" = "application/json"
  }
  request_body = jsonencode({
    action   = "login",
    username = var.controller_admin_username,
    password = var.controller_admin_password,
  })
  retry {
    attempts     = 5
    min_delay_ms = 1000
  }
  lifecycle {
    postcondition {
      condition     = jsondecode(self.response_body)["return"]
      error_message = "Failed to login to the controller: ${jsondecode(self.response_body)["reason"]}"
    }
  }
}

resource "terracurl_request" "azure_access_account" {
  name            = "azure_access_account"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    action                        = "setup_account_profile",
    CID                           = jsondecode(data.http.controller_login.response_body)["CID"],
    account_name                  = var.access_account_name,
    cloud_type                    = "8",
    account_email                 = var.account_email,
    arm_subscription_id           = var.arm_subscription_id,
    arm_application_endpoint      = var.arm_directory_id,
    arm_application_client_id     = var.arm_client_id,
    arm_application_client_secret = var.arm_application_key,
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 5
  retry_interval = 1

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to create access account: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [data.http.controller_login]
}

# Enable controller security group management
resource "terracurl_request" "enable_controller_security_group_management" {
  name            = "enable_controller_security_group_management"
  url             = "https://${var.controller_public_ip}/v2/api"
  method          = "POST"
  skip_tls_verify = true
  request_body = jsonencode({
    action : "enable_controller_security_group_management",
    CID = jsondecode(data.http.controller_login.response_body)["CID"],
    access_account_name : var.access_account_name
  })

  headers = {
    Content-Type = "application/json"
  }

  response_codes = [
    200,
  ]

  max_retry      = 3
  retry_interval = 3

  lifecycle {
    postcondition {
      condition     = jsondecode(self.response)["return"]
      error_message = "Failed to enable security group management: ${jsondecode(self.response)["reason"]}"
    }

    ignore_changes = all
  }

  depends_on = [terracurl_request.azure_access_account]
}
