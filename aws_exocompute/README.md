# AWS Exocompute

The configuration in this directory onboards an AWS account to RSC and creates an Exocompute configuration for the
account.

Note, the `cluster_security_group_id` and `node_security_group_id` input variables must be specified if the
`rubrikinc/polaris-cloud-native-exocompute-networking/aws` Terraform module is used to create the VPC resources.

## Usage

To run this example you need to execute:
```bash
$ terraform init
$ terraform plan
$ terraform apply
```
Note that this example may create resources which can cost money. Run `terraform destroy` when you don't need these
resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.70.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.70.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account"></a> [account](#module\_account) | ../aws_cnp_account | n/a |

## Resources

| Name | Type |
|------|------|
| [polaris_aws_exocompute.exocompute](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_exocompute) | resource |
| [time_sleep.wait_for_rsc](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | AWS cluster / control plane security group ID. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | AWS account name. | `string` | n/a | yes |
| <a name="input_native_id"></a> [native\_id](#input\_native\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | AWS node / worker security group ID. | `string` | `null` | no |
| <a name="input_subnet1"></a> [subnet1](#input\_subnet1) | AWS subnet 1 ID. | `string` | n/a | yes |
| <a name="input_subnet2"></a> [subnet2](#input\_subnet2) | AWS subnet 2 ID. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created. | `map(string)` | <pre>{<br/>  "Environment": "test",<br/>  "Example": "aws_exocompute",<br/>  "Module": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_exocompute_id"></a> [exocompute\_id](#output\_exocompute\_id) | RSC Exocompute configuration ID. |
<!-- END_TF_DOCS -->
