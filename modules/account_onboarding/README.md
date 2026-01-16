<!-- BEGIN_TF_DOCS -->
# terraform-aviatrix-azure-controlplane - account-onboarding

### Description
This submodule helps with onboarding the first cloud account onto the controller.

### Usage Example
```hcl
module "account_onboarding" {
  source = "./modules/account_onboarding"

  controller_public_ip      = "1.2.3.4"
  controller_admin_password = "my-password"
  access_account_name       = "aws"
  account_email             = "admin@domain.com"
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_account_name"></a> [access\_account\_name](#input\_access\_account\_name) | Access account name | `string` | `"AWS"` | no |
| <a name="input_account_email"></a> [account\_email](#input\_account\_email) | Account email address | `string` | n/a | yes |
| <a name="input_aws_role_app"></a> [aws\_role\_app](#input\_aws\_role\_app) | n/a | `string` | `"aviatrix-role-app"` | no |
| <a name="input_aws_role_ec2"></a> [aws\_role\_ec2](#input\_aws\_role\_ec2) | n/a | `string` | `"aviatrix-role-ec2"` | no |
| <a name="input_controller_admin_password"></a> [controller\_admin\_password](#input\_controller\_admin\_password) | aviatrix controller admin password | `string` | n/a | yes |
| <a name="input_controller_admin_username"></a> [controller\_admin\_username](#input\_controller\_admin\_username) | aviatrix controller admin username | `string` | `"admin"` | no |
| <a name="input_controller_public_ip"></a> [controller\_public\_ip](#input\_controller\_public\_ip) | aviatrix controller public ip address(required) | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->