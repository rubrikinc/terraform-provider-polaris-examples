# AWS account onboarding

The configuration in this directory adds AWS accounts to RSC using the `polaris_aws_account` resource. It demonstrates
onboarding an outpost account and an account with features depending on an outpost account, in this case the
`cyber_recovery_data_scanning`, `data_scanning`, and `dspm` features.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.0.0 |

## Resources

| Name | Type |
|------|------|
| [polaris_aws_account.outpost](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_account) | resource |
| [polaris_aws_account.account](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_outpost_profile"></a> [outpost\_profile](#input\_outpost\_profile) | Outpost account AWS profile. | `string` | n/a | yes |
| <a name="input_account_profile"></a> [account\_profile](#input\_account\_profile) | Account AWS profile. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
