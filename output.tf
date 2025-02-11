output "controller_public_ip" {
  value = var.module_config.controller_deployment ? module.controller_build[0].public_ip : null
}

output "controller_private_ip" {
  value = var.module_config.controller_deployment ? module.controller_build[0].private_ip : null
}

output "copilot_public_ip" {
  value = var.module_config.copilot_deployment ? module.copilot_build[0].public_ip : null
}

output "copilot_private_ip" {
  value = var.module_config.copilot_deployment ? module.copilot_build[0].private_ip : null
}

output "controller_instance_id" {
  value = var.module_config.controller_deployment ? module.controller_build[0].instance_id : null
}

output "controller_name" {
  value = var.module_config.controller_deployment ? module.controller_build[0].controller_name : null
}

output "controller_security_group_id" {
  value = module.controller_build[0].security_group_id
}
