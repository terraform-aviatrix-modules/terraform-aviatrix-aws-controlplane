module "iam_roles" {
  count  = var.module_config.iam_roles ? 1 : 0
  source = "./modules/iam_roles"
}

module "controller_build" {
  count = var.module_config.controller_deployment ? 1 : 0

  source = "./modules/controller_build"
  // please do not use special characters such as `\/"[]:|<>+=;,?*@&~!#$%^()_{}'` in the controller_name
  controller_name = var.controller_name

  instance_type      = var.controller_instance_type
  incoming_ssl_cidrs = local.controller_allowed_cidrs
  use_existing_vpc   = var.use_existing_vpc
  vpc_id             = var.vpc_id
  subnet_id          = var.subnet_id

  availability_zone    = var.availability_zone
  vpc_cidr             = var.controlplane_vpc_cidr
  subnet_cidr          = var.controlplane_subnet_cidr
  environment          = var.environment                     #For internal use only
  ami_id               = var.controller_ami_id               #For internal use only
  use_existing_keypair = var.controller_use_existing_keypair #For internal use only
  key_pair_name        = var.controller_key_pair_name        #For internal use only
  tags                 = var.tags
  name_prefix          = var.name_prefix
  depends_on = [
    module.iam_roles
  ]
}

module "controller_init" {
  count = var.module_config.controller_initialization ? 1 : 0

  source  = "terraform-aviatrix-modules/controller-init/aviatrix"
  version = "v1.0.4"

  controller_public_ip      = module.controller_build[0].public_ip
  controller_private_ip     = module.controller_build[0].private_ip
  controller_admin_email    = var.controller_admin_email
  controller_admin_password = var.controller_admin_password
  customer_id               = var.customer_id
  wait_for_setup_duration   = "10m"
  controller_version        = var.controller_version

  depends_on = [
    module.controller_build
  ]
}

#Copilot
module "copilot_build" {
  count = var.module_config.copilot_deployment ? 1 : 0

  source = "./modules/copilot_build"

  use_existing_vpc = true
  subnet_id        = module.controller_build[0].subnet_id
  vpc_id           = module.controller_build[0].vpc_id

  controller_public_ip     = module.controller_build[0].public_ip
  controller_private_ip    = module.controller_build[0].private_ip
  copilot_name             = var.copilot_name
  default_data_volume_name = "/dev/sdf"
  default_data_volume_size = "100"
  environment              = var.environment                  #For internal use only
  use_existing_keypair     = var.copilot_use_existing_keypair #For internal use only
  key_pair_name            = var.copilot_key_pair_name        #For internal use only
  tags                     = var.tags
  name_prefix              = var.name_prefix
  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "Tcp"
      port     = 443
      cidrs    = var.incoming_ssl_cidrs
    }
    "udp_5000_cidrs" = {
      protocol = "Udp"
      port     = 5000
      cidrs    = [format("%s/32", module.controller_build[0].public_ip)]
    },
    "udp_31283_cidrs" = {
      protocol = "Udp"
      port     = 31283
      cidrs    = [format("%s/32", module.controller_build[0].public_ip)]
    }
  }
}

module "copilot_init" {
  count = var.module_config.copilot_initialization ? 1 : 0

  source  = "terraform-aviatrix-modules/copilot-init/aviatrix"
  version = "v1.0.5"

  controller_public_ip             = module.controller_build[0].public_ip
  controller_admin_password        = var.controller_admin_password
  copilot_public_ip                = module.copilot_build[0].public_ip
  service_account_email            = var.controller_admin_email
  copilot_service_account_password = local.copilot_service_account_password

  depends_on = [
    module.controller_init
  ]
}

#Onboard the account
module "account_onboarding" {
  count  = var.module_config.account_onboarding ? 1 : 0
  source = "./modules/account_onboarding"

  controller_public_ip      = module.controller_build[0].public_ip
  controller_admin_password = var.controller_admin_password

  access_account_name = var.access_account_name
  account_email       = var.account_email

  depends_on = [
    module.controller_init,
  ]
}
