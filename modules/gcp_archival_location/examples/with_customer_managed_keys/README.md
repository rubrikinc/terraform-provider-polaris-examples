# Archival Location with Customer Managed Keys Example

The configuration in this directory demonstrates how to create an RSC archival location for GCP cloud native workloads
with customer-managed encryption keys. The configuration performs the following steps:

1. Create a GCP service account for RSC.
2. Onboard the GCP project to RSC.
3. Create a KMS key ring and crypto key.
4. Create an RSC archival location using a customer-managed key in the `us-central1` region.

The crypto key is created with a 30-day automatic rotation period and lifecycle protection to prevent accidental
deletion. Note, when using customer-managed keys, the `ENCRYPTION` permission group must be included when onboarding
the GCP project. This grants RSC additional permissions to access KMS services.

## Usage

To run this example, execute the following:
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
| <a name="requirement_google"></a> [google](#requirement\_google) | >=7.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.2.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | >=3.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_crypto_key"></a> [crypto\_key](#module\_crypto\_key) | ../../../gcp_archival_location/modules/crypto_key | n/a |
| <a name="module_gcp_archival_location"></a> [gcp\_archival\_location](#module\_gcp\_archival\_location) | ../../../gcp_archival_location | n/a |
| <a name="module_gcp_project"></a> [gcp\_project](#module\_gcp\_project) | ../../../gcp_project | n/a |
| <a name="module_service_account"></a> [service\_account](#module\_service\_account) | ../../../gcp_project/modules/service_account | n/a |

## Resources

| Name | Type |
|------|------|
| [null_resource.prevent_destroy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to GCP resources created which supports labels. | `map(string)` | <pre>{<br/>  "example": "basic",<br/>  "module": "gcp_archival_location",<br/>  "repository": "terraform-provider-polaris-examples"<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
