# AWS Cloud Cluster

The configuration in this directory onboards an AWS account to RSC and creates an AWS cloud cluster using RSC.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.1.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.1.7 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cnp_account"></a> [aws\_cnp\_account](#module\_aws\_cnp\_account) | ../aws_cnp_account | n/a |

## Resources

| Name | Type |
|------|------|
| [polaris_aws_cloud_cluster.cces](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_cloud_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | AWS account name. | `string` | n/a | yes |
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Admin email address. | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | AWS S3 bucket name. | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cloud cluster name. | `string` | n/a | yes |
| <a name="input_dns_search_domains"></a> [dns\_search\_domains](#input\_dns\_search\_domains) | DNS search domains. | `set(string)` | n/a | yes |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | AWS EC2 instance profile name. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | AWS security group IDs. | `set(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | AWS subnet ID. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created. | `map(string)` | <pre>{<br/>  "Environment": "test",<br/>  "Example": "aws_cloud_cluster",<br/>  "Module": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_cluster_id"></a> [cloud\_cluster\_id](#output\_cloud\_cluster\_id) | n/a |
<!-- END_TF_DOCS -->
