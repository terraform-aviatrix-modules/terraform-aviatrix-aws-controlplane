<!-- BEGIN_TF_DOCS -->
# terraform-aviatrix-aws-controlplane

### Description
This module deploys the Aviatrix control plane, or individual parts thereof.

### Requirements

### Compatibility
Module version | Terraform version
:--- | :---
v0.9.0 | >= 1.3.0

### Usage Example
```hcl
module "control_plane" {
  source  = "terraform-aviatrix-modules/aws-controlplane/aviatrix"
  version = "0.9.0"

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
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_account_name"></a> [access\_account\_name](#input\_access\_account\_name) | aviatrix controller access account name | `string` | n/a | yes |
| <a name="input_account_email"></a> [account\_email](#input\_account\_email) | aviatrix controller access account email | `string` | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | The Availability zone in which to deploy the controlplane. | `string` | `""` | no |
| <a name="input_controller_admin_email"></a> [controller\_admin\_email](#input\_controller\_admin\_email) | aviatrix controller admin email address | `string` | n/a | yes |
| <a name="input_controller_admin_password"></a> [controller\_admin\_password](#input\_controller\_admin\_password) | aviatrix controller admin password | `string` | n/a | yes |
| <a name="input_controller_ec2_role_name"></a> [controller\_ec2\_role\_name](#input\_controller\_ec2\_role\_name) | EC2 role for controller | `string` | `null` | no |
| <a name="input_controller_instance_type"></a> [controller\_instance\_type](#input\_controller\_instance\_type) | The instance type used for deploying the controller. | `string` | `"t3.large"` | no |
| <a name="input_controller_name"></a> [controller\_name](#input\_controller\_name) | Customized Name for Aviatrix Controller | `string` | `"Aviatrix-Controller"` | no |
| <a name="input_controller_version"></a> [controller\_version](#input\_controller\_version) | Aviatrix Controller version | `string` | `"latest"` | no |
| <a name="input_controlplane_subnet_cidr"></a> [controlplane\_subnet\_cidr](#input\_controlplane\_subnet\_cidr) | CIDR for controlplane subnet. | `string` | `"10.0.0.0/24"` | no |
| <a name="input_controlplane_vpc_cidr"></a> [controlplane\_vpc\_cidr](#input\_controlplane\_vpc\_cidr) | CIDR for controller VPC. | `string` | `"10.0.0.0/24"` | no |
| <a name="input_copilot_instance_type"></a> [copilot\_instance\_type](#input\_copilot\_instance\_type) | The instance type used for deploying copilot. | `string` | `null` | no |
| <a name="input_copilot_name"></a> [copilot\_name](#input\_copilot\_name) | Customized Name for Aviatrix Copilot | `string` | `"Aviatrix-Copilot"` | no |
| <a name="input_copilot_service_account_password"></a> [copilot\_service\_account\_password](#input\_copilot\_service\_account\_password) | n/a | `string` | `""` | no |
| <a name="input_customer_id"></a> [customer\_id](#input\_customer\_id) | aviatrix customer license id | `string` | n/a | yes |
| <a name="input_incoming_ssl_cidrs"></a> [incoming\_ssl\_cidrs](#input\_incoming\_ssl\_cidrs) | Incoming cidrs for security group used by controller | `list(string)` | n/a | yes |
| <a name="input_module_config"></a> [module\_config](#input\_module\_config) | n/a | `map` | <pre>{<br/>  "account_onboarding": true,<br/>  "controller_deployment": true,<br/>  "controller_initialization": true,<br/>  "copilot_deployment": true,<br/>  "copilot_initialization": true,<br/>  "iam_roles": true<br/>}</pre> | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to apply to all resources | `string` | `""` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID, only required when use\_existing\_vpc is true. | `string` | `""` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | subnet name, only required when use\_existing\_vpc is true. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_use_existing_vpc"></a> [use\_existing\_vpc](#input\_use\_existing\_vpc) | Flag to indicate whether to use an existing VPC | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC name, only required when use\_existing\_vpc is true | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controller_instance_id"></a> [controller\_instance\_id](#output\_controller\_instance\_id) | n/a |
| <a name="output_controller_name"></a> [controller\_name](#output\_controller\_name) | n/a |
| <a name="output_controller_private_ip"></a> [controller\_private\_ip](#output\_controller\_private\_ip) | n/a |
| <a name="output_controller_public_ip"></a> [controller\_public\_ip](#output\_controller\_public\_ip) | n/a |
| <a name="output_controller_security_group_id"></a> [controller\_security\_group\_id](#output\_controller\_security\_group\_id) | n/a |
| <a name="output_controller_subnet_id"></a> [controller\_subnet\_id](#output\_controller\_subnet\_id) | n/a |
| <a name="output_controller_vpc_id"></a> [controller\_vpc\_id](#output\_controller\_vpc\_id) | n/a |
| <a name="output_copilot_instance_id"></a> [copilot\_instance\_id](#output\_copilot\_instance\_id) | n/a |
| <a name="output_copilot_private_ip"></a> [copilot\_private\_ip](#output\_copilot\_private\_ip) | n/a |
| <a name="output_copilot_public_ip"></a> [copilot\_public\_ip](#output\_copilot\_public\_ip) | n/a |
| <a name="output_copilot_security_group_id"></a> [copilot\_security\_group\_id](#output\_copilot\_security\_group\_id) | n/a |
<!-- END_TF_DOCS -->