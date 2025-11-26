# GCP Service Account Module

This module creates a GCP service account and generates a service account key. It is primarily used by the `gcp_project`
tests, but can also be used as part of the GCP project onboarding process. The module supports key rotation through the
`rotation_trigger` variable, which allows you to rotate the service account key by changing the trigger value. Note,
for more advanced forms of service account key management, consider using the services provided by GCP directly.

## Usage

### Basic Usage

```terraform
module "service_account" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_project/modules/service_account"
}
```

### Custom Account ID and Display Name

```terraform
module "service_account" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_project/modules/service_account"

  account_id   = "rubrik-rsc-account"
  display_name = "Rubrik Security Cloud Service Account"
}
```

### With Key Rotation

```terraform
module "service_account" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_project/modules/service_account"

  account_id = "rubrik-rsc-account"

  # When this value changes, the service account key is rotated.
  rotation_trigger = "2025-11-13"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >=7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=7.0.0 |

## Resources

| Name | Type |
|------|------|
| [google_service_account.service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | The unique identifier for the service account within the project. Must be between 6 and 30 characters and can contain lowercase letters, numbers, and hyphens. | `string` | `"rubrik-service-account"` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | A human-readable name for the service account. If not specified, the module will automatically generate a display name from the `account_id`. | `string` | `null` | no |
| <a name="input_rotation_trigger"></a> [rotation\_trigger](#input\_rotation\_trigger) | A trigger to rotate the service account key. The trigger can be any string. When the trigger changes, the service account key will be rotated. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_id"></a> [service\_account\_id](#output\_service\_account\_id) | The fully qualified GCP service account ID. |
| <a name="output_service_account_key"></a> [service\_account\_key](#output\_service\_account\_key) | The base64-encoded private key for the GCP service account. |
<!-- END_TF_DOCS -->
