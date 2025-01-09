<!-- BEGIN_TF_DOCS -->
# terraform-aviatrix-azure-controlplane - controller-build

### Description
This submodule helps with building the controller instance.

### Usage Example
```hcl
module "controller_build" {
  source = "./modules/controller_build"

  controller_name    = "My-Controller"
  incoming_ssl_cidrs = ["1.2.3.4/32"]
  vpc_cidr           = "10.0.0.0/20"
  subnet_cidr        = "10.0.0.0/24"
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | AMI ID for controller. If unset, use official image. | `string` | `""` | no |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone | `string` | `""` | no |
| <a name="input_controller_name"></a> [controller\_name](#input\_controller\_name) | Name of controller that will be launched. If not set, default name will be used. | `string` | `""` | no |
| <a name="input_ec2_role_name"></a> [ec2\_role\_name](#input\_ec2\_role\_name) | EC2 role for controller | `string` | `""` | no |
| <a name="input_incoming_ssl_cidrs"></a> [incoming\_ssl\_cidrs](#input\_incoming\_ssl\_cidrs) | Incoming cidr for security group used by controller | `list(string)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Controller instance size | `string` | `"t3.large"` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | Key pair name | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Additional name prefix for your environment resources | `string` | `""` | no |
| <a name="input_root_volume_encrypted"></a> [root\_volume\_encrypted](#input\_root\_volume\_encrypted) | Whether the root volume is encrypted | `bool` | `true` | no |
| <a name="input_root_volume_kms_key_id"></a> [root\_volume\_kms\_key\_id](#input\_root\_volume\_kms\_key\_id) | ARN for the key used to encrypt the root volume | `string` | `""` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume disk size for controller | `number` | `64` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | Root volume type for controller | `string` | `"gp3"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Subnet in which you want launch Aviatrix controller | `string` | `"10.0.1.0/24"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID, only required when use\_existing\_vpc is true | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of common tags which should be used for module resources | `map(string)` | `{}` | no |
| <a name="input_termination_protection"></a> [termination\_protection](#input\_termination\_protection) | Enable/disable switch for termination protection | `bool` | `true` | no |
| <a name="input_use_existing_keypair"></a> [use\_existing\_keypair](#input\_use\_existing\_keypair) | Flag to indicate whether to use an existing key pair | `bool` | `false` | no |
| <a name="input_use_existing_vpc"></a> [use\_existing\_vpc](#input\_use\_existing\_vpc) | Flag to indicate whether to use an existing VPC | `bool` | `false` | no |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | User data for starting the controller | `string` | `""` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC in which you want launch Aviatrix controller | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID, required when use\_existing\_vpc is true | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | Controller instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP of the controller |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP of the controller |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group id used by Aviatrix controller |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | Subnet where Aviatrix controller was built |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC where Aviatrix controller was built |
<!-- END_TF_DOCS -->