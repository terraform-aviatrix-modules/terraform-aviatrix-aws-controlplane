<!-- BEGIN_TF_DOCS -->
# terraform-aviatrix-azure-controlplane - copilot-build

### Description
This submodule helps with building a copilot instance.

### Usage Example
```hcl
module "copilot_build" {
  source = "./modules/copilot_build"

  use_existing_vpc = true
  subnet_id        = "subnet-123456789"
  vpc_id           = "vpc-123456789"

  controller_public_ip     = "1.2.3.4"
  controller_private_ip    = "10.2.3.4"
  copilot_name             = "my-copilot"
  default_data_volume_name = "/dev/sdf"
  default_data_volume_size = "100"

  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "Tcp"
      port     = 443
      cidrs    = ["1.2.3.4/32"]
    }
    "udp_5000_cidrs" = {
      protocol = "Udp"
      port     = 5000
      cidrs    = ["1.2.3.4/32"]
    },
    "udp_31283_cidrs" = {
      protocol = "Udp"
      port     = 31283
      cidrs    = ["1.2.3.4/32"]
    }
  }
}
```
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_volumes"></a> [additional\_volumes](#input\_additional\_volumes) | n/a | <pre>map(object({<br/>    device_name = string,<br/>    volume_id   = string,<br/>  }))</pre> | `{}` | no |
| <a name="input_allowed_cidrs"></a> [allowed\_cidrs](#input\_allowed\_cidrs) | n/a | <pre>map(object({<br/>    protocol = string,<br/>    port     = number,<br/>    cidrs    = set(string),<br/>  }))</pre> | n/a | yes |
| <a name="input_availability_zone"></a> [availability\_zone](#input\_availability\_zone) | Availability zone | `string` | `""` | no |
| <a name="input_controller_private_ip"></a> [controller\_private\_ip](#input\_controller\_private\_ip) | Controller private IP | `string` | n/a | yes |
| <a name="input_controller_public_ip"></a> [controller\_public\_ip](#input\_controller\_public\_ip) | Controller public IP | `string` | `"0.0.0.0"` | no |
| <a name="input_copilot_name"></a> [copilot\_name](#input\_copilot\_name) | Name of copilot that will be launched | `string` | `""` | no |
| <a name="input_default_data_volume_name"></a> [default\_data\_volume\_name](#input\_default\_data\_volume\_name) | Name of default data volume. If not set, no default data volume will be created | `string` | `""` | no |
| <a name="input_default_data_volume_size"></a> [default\_data\_volume\_size](#input\_default\_data\_volume\_size) | Size of default data volume | `number` | `50` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Copilot instance size | `string` | `""` | no |
| <a name="input_is_cluster"></a> [is\_cluster](#input\_is\_cluster) | Flag to indicate whether the copilot is for a cluster | `bool` | `false` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | Key pair which should be used by Aviatrix Copilot | `string` | `"aviatrix_copilot_kp"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Additional name prefix for your environment resources | `string` | `""` | no |
| <a name="input_private_mode"></a> [private\_mode](#input\_private\_mode) | Flag to indicate whether the copilot is for private mode | `bool` | `false` | no |
| <a name="input_root_volume_size"></a> [root\_volume\_size](#input\_root\_volume\_size) | Root volume size for copilot | `number` | `30` | no |
| <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type) | Root volume type for copilot | `string` | `"gp3"` | no |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | Subnet in which you want launch Aviatrix Copilot | `string` | `"10.0.1.0/24"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID, only required when use\_existing\_vpc is true | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of common tags which should be used for module resources | `map(string)` | `{}` | no |
| <a name="input_type"></a> [type](#input\_type) | Type of billing, can be 'Copilot' or 'CopilotARM' | `string` | `"Copilot"` | no |
| <a name="input_use_existing_keypair"></a> [use\_existing\_keypair](#input\_use\_existing\_keypair) | Flag to indicate whether to use an existing key pair | `bool` | `false` | no |
| <a name="input_use_existing_vpc"></a> [use\_existing\_vpc](#input\_use\_existing\_vpc) | Flag to indicate whether to use an existing VPC | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC in which you want launch Aviatrix Copilot | `string` | `"10.0.0.0/16"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID, required when use\_existing\_vpc is true | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ec2-info"></a> [ec2-info](#output\_ec2-info) | EC2 instance info |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address of the Aviatrix Copilot |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP address of the Aviatrix Copilot |
| <a name="output_region"></a> [region](#output\_region) | Current AWS region |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC name |
<!-- END_TF_DOCS -->