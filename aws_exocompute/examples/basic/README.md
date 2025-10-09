# Basic AWS Exocompute creation

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

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=5.70.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cnp_account"></a> [aws\_cnp\_account](#module\_aws\_cnp\_account) | ../../../aws_cnp_account | n/a |
| <a name="module_aws_exocompute"></a> [aws\_exocompute](#module\_aws\_exocompute) | ../.. | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | AWS account name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created. | `map(string)` | <pre>{<br/>  "Environment": "test",<br/>  "Example": "aws_exocompute",<br/>  "Module": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
