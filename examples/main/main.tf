module "control_plane" {
  source  = "terraform-aviatrix-modules/aws-controlplane/aviatrix"
  version = "1.0.3"

  controller_name           = "my_controller"
  incoming_ssl_cidrs        = ["1.2.3.4"]
  controller_admin_email    = "admin@domain.com"
  controller_admin_password = "mysecretpassword"
  account_email             = "admin@domain.com"
  access_account_name       = "AWS"
  customer_id               = "xxxxxxx-abu-xxxxxxxxx"
}

output "controlplane_data" {
  value = module.control_plane
}
