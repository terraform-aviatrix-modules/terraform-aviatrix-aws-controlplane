This is a deployment example for this module.

Execute the following Terraform code:

```hcl
module "account_onboarding" {
  source = "./modules/account_onboarding"

  controller_public_ip      = "1.2.3.4"
  controller_admin_password = "my_password"

  access_account_name = "Azure"
  account_email       = "admin@domain.com"
  arm_subscription_id = "subscription_id"
  arm_directory_id    = "directory_id"
  arm_client_id       = "clien_id"
  arm_application_key = "application_key"
}
```