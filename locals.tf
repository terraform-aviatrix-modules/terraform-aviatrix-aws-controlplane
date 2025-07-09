data "aws_availability_zones" "all" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

data "aws_ec2_instance_type_offering" "offering" {
  for_each = toset(data.aws_availability_zones.all.names)

  filter {
    name   = "instance-type"
    values = ["t2.micro", "t3.micro", var.controller_instance_type]
  }

  filter {
    name   = "location"
    values = [each.value]
  }

  location_type = "availability-zone"

  preferred_instance_types = [var.controller_instance_type, "t3.micro", "t2.micro"]
}

locals {
  copilot_service_account_password = coalesce(var.copilot_service_account_password, var.controller_admin_password)
  copilot_public_ip                = var.module_config.copilot_deployment ? [format("%s/32", module.copilot_build[0].public_ip)] : []
  copilot_private_ip               = var.module_config.copilot_deployment ? [format("%s/32", module.copilot_build[0].private_ip)] : []
  copilot_ips                      = concat(local.copilot_private_ip, local.copilot_public_ip)
  controller_allowed_cidrs         = concat(var.incoming_ssl_cidrs, local.copilot_ips)
  default_az                       = keys({ for az, details in data.aws_ec2_instance_type_offering.offering : az => details.instance_type if details.instance_type == var.controller_instance_type })[0]
}
