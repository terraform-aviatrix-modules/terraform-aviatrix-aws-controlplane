<!-- BEGIN_TF_DOCS -->
# terraform-aviatrix-azure-controlplane - controller-sg-management

### Description
This submodule helps with disabling security group management on destroy.

### Usage Example
```hcl
module "controller_sg_mgmt" {
  source                    = "./modules/controller_sg_mgmt"
  controller_public_ip      = "1.2.3.4"
  controller_admin_username = "admin"
  controller_admin_password = "password"
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_account_name"></a> [access\_account\_name](#input\_access\_account\_name) | Aviatrix access account name | `string` | n/a | yes |
| <a name="input_controller_admin_password"></a> [controller\_admin\_password](#input\_controller\_admin\_password) | aviatrix controller admin password | `string` | n/a | yes |
| <a name="input_controller_admin_username"></a> [controller\_admin\_username](#input\_controller\_admin\_username) | aviatrix controller admin username | `string` | `"admin"` | no |
| <a name="input_controller_public_ip"></a> [controller\_public\_ip](#input\_controller\_public\_ip) | aviatrix controller public ip address(required) | `string` | n/a | yes |
| <a name="input_dummy_url"></a> [dummy\_url](#input\_dummy\_url) | Dummy URL used by terracurl during apply operations. | `string` | `"https://checkip.amazonaws.com"` | no |
| <a name="input_enable_copilot_security_group_management"></a> [enable\_copilot\_security\_group\_management](#input\_enable\_copilot\_security\_group\_management) | Enable Copilot security group management | `bool` | `true` | no |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | EC2 instance ID for the Aviatrix Copilot instance. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the copilot instance is deployed. | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END_TF_DOCS -->