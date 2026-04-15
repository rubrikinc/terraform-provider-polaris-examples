# Role Chaining

The configuration in this directory adds two AWS accounts to RSC using the IAM roles workflow. The first account is
onboarded with the `ROLE_CHAINING` feature, and the second account is onboarded as a role-chained account, using the
first account's cloud account ID as the `role_chaining_account_id`.

Each account uses its own aliased AWS provider with a separate named profile (`role-chaining` and `role-chained`),
allowing the two accounts to use different credentials. Update the profile names to match your AWS CLI configuration.

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
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=6.0.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.6.3 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_role_chained_account"></a> [role\_chained\_account](#module\_role\_chained\_account) | ../.. | n/a |
| <a name="module_role_chaining_account"></a> [role\_chaining\_account](#module\_role\_chaining\_account) | ../.. | n/a |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_role_chained_account_id"></a> [role\_chained\_account\_id](#input\_role\_chained\_account\_id) | AWS account ID for the role-chained account. | `string` | n/a | yes |
| <a name="input_role_chained_account_name"></a> [role\_chained\_account\_name](#input\_role\_chained\_account\_name) | AWS account name for the role-chained account. | `string` | n/a | yes |
| <a name="input_role_chaining_account_id"></a> [role\_chaining\_account\_id](#input\_role\_chaining\_account\_id) | AWS account ID for the role-chaining account. | `string` | n/a | yes |
| <a name="input_role_chaining_account_name"></a> [role\_chaining\_account\_name](#input\_role\_chaining\_account\_name) | AWS account name for the role-chaining account. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created. | `map(string)` | <pre>{<br/>  "Example": "role_chaining",<br/>  "Module": "aws_iam_account",<br/>  "Repository": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
