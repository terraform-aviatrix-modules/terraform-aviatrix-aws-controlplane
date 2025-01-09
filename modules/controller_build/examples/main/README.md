This is a deployment example for this module.

Execute the following Terraform code:

```hcl
module "controller_build" {
  source = "./modules/controller_build"

  controller_name    = "My-Controller"
  incoming_ssl_cidrs = ["1.2.3.4/32"]
  vpc_cidr           = "10.0.0.0/20"
  subnet_cidr        = "10.0.0.0/24"
}

```