This is a deployment example for this module.

Execute the following Terraform code:

```hcl
module "account_onboarding" {
  source = "./modules/account_onboarding"

  controller_public_ip      = "1.2.3.4"
  controller_admin_password = "my-password"
  access_account_name = "aws"
  account_email       = "admin@domain.com"
}
```