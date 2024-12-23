<!-- BEGIN_TF_DOCS -->
# terraform-aviatrix-azure-controlplane - account-onboarding

### Description
This submodule helps with onboarding the first cloud account onto the controller.

### Usage Example
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
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_account_name"></a> [access\_account\_name](#input\_access\_account\_name) | Access account name | `string` | `"Azure"` | no |
| <a name="input_account_email"></a> [account\_email](#input\_account\_email) | Account email address | `string` | n/a | yes |
| <a name="input_arm_application_key"></a> [arm\_application\_key](#input\_arm\_application\_key) | Azure application key | `string` | n/a | yes |
| <a name="input_arm_client_id"></a> [arm\_client\_id](#input\_arm\_client\_id) | Azure client ID | `string` | n/a | yes |
| <a name="input_arm_directory_id"></a> [arm\_directory\_id](#input\_arm\_directory\_id) | Azure directory ID | `string` | n/a | yes |
| <a name="input_arm_subscription_id"></a> [arm\_subscription\_id](#input\_arm\_subscription\_id) | Azure subscription ID | `string` | n/a | yes |
| <a name="input_controller_admin_password"></a> [controller\_admin\_password](#input\_controller\_admin\_password) | aviatrix controller admin password | `string` | n/a | yes |
| <a name="input_controller_admin_username"></a> [controller\_admin\_username](#input\_controller\_admin\_username) | aviatrix controller admin username | `string` | `"admin"` | no |
| <a name="input_controller_public_ip"></a> [controller\_public\_ip](#input\_controller\_public\_ip) | aviatrix controller public ip address(required) | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->