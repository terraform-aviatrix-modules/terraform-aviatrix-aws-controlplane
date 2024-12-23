## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.aviatrix_role_ec2_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.aviatrix_app_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.aviatrix_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.aviatrix_role_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.aviatrix_role_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aviatrix_role_app_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.aviatrix_role_ec2_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.aviatrix-assume-role-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.aviatrix-role-ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.policy_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [http_http.iam_policy_ec2_role](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_role_name"></a> [app\_role\_name](#input\_app\_role\_name) | APP role name | `string` | `""` | no |
| <a name="input_ec2_role_name"></a> [ec2\_role\_name](#input\_ec2\_role\_name) | EC2 role name | `string` | `""` | no |
| <a name="input_external_controller_account_id"></a> [external\_controller\_account\_id](#input\_external\_controller\_account\_id) | n/a | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for your EC2 role name and APP role name | `string` | `""` | no |
| <a name="input_secondary_account_ids"></a> [secondary\_account\_ids](#input\_secondary\_account\_ids) | n/a | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aviatrix_app_policy_arn"></a> [aviatrix\_app\_policy\_arn](#output\_aviatrix\_app\_policy\_arn) | Aviatrix policy ARN for application |
| <a name="output_aviatrix_assume_role_policy_arn"></a> [aviatrix\_assume\_role\_policy\_arn](#output\_aviatrix\_assume\_role\_policy\_arn) | Aviatrix assume role policy ARN |
| <a name="output_aviatrix_role_app_arn"></a> [aviatrix\_role\_app\_arn](#output\_aviatrix\_role\_app\_arn) | Aviatrix role ARN for application |
| <a name="output_aviatrix_role_app_name"></a> [aviatrix\_role\_app\_name](#output\_aviatrix\_role\_app\_name) | Aviatrix role name for application |
| <a name="output_aviatrix_role_ec2_arn"></a> [aviatrix\_role\_ec2\_arn](#output\_aviatrix\_role\_ec2\_arn) | Aviatrix role ARN for EC2 |
| <a name="output_aviatrix_role_ec2_name"></a> [aviatrix\_role\_ec2\_name](#output\_aviatrix\_role\_ec2\_name) | Aviatrix role name for EC2 |
| <a name="output_aviatrix_role_ec2_profile_arn"></a> [aviatrix\_role\_ec2\_profile\_arn](#output\_aviatrix\_role\_ec2\_profile\_arn) | Aviatrix role EC2 profile ARN for application |
| <a name="output_aws_account_id"></a> [aws\_account\_id](#output\_aws\_account\_id) | AWS account Id |
