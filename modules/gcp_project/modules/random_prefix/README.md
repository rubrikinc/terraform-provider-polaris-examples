# Random Prefix Module

This module generates a random prefix by combining a fixed prefix with a randomly generated alphanumeric suffix. This is
useful for creating unique identifiers for GCP resources such as IAM role IDs, service account names, or other resources
that require unique naming. It is primarily used by the `gcp_project` tests to create unique IAM role IDs.

> [!NOTE]
> The random suffix is generated once and persisted in the Terraform state.

## Usage

```terraform
module "random_prefix" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_project/modules/random_prefix"

  prefix = "rubrik_role"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_random"></a> [random](#requirement\_random) | >=3.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | >=3.7.0 |

## Resources

| Name | Type |
|------|------|
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_length"></a> [length](#input\_length) | Length of the generated random suffix of the random prefix. | `number` | `8` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Fixed prefix for the random prefix. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_result"></a> [result](#output\_result) | Result of the random prefix. |
<!-- END_TF_DOCS -->
