This is a deployment example for this module.

Execute the following Terraform code:

```hcl
module "controller_sg_mgmt" {
  source                    = "./modules/controller_sg_mgmt"
  controller_public_ip      = "1.2.3.4"
  controller_admin_username = "admin"
  controller_admin_password = "password"
}
```