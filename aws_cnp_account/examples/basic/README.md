# Basic AWS CNP account onboarding

The configuration in this directory adds an AWS account to RSC using the IAM roles workflow.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cnp_account"></a> [aws\_cnp\_account](#module\_aws\_cnp\_account) | ../.. | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | AWS account name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created. | `map(string)` | <pre>{<br/>  "Environment": "test",<br/>  "Example": "aws_cnp_account",<br/>  "Module": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
