locals {
  copilot_service_account_password = coalesce(var.copilot_service_account_password, var.controller_admin_password)
  copilot_public_ip                = var.module_config.copilot_deployment ? [format("%s/32", module.copilot_build[0].public_ip)] : []
  controller_allowed_cidrs         = concat(var.incoming_ssl_cidrs, local.copilot_public_ip)
}
