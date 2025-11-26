# GCP Archival Location Module

This module manages an RSC archival location for storing snapshots of GCP cloud native workloads. The module optionally
configures customer-managed encryption keys for enhanced security control. To create a GCP archival location, you first
need to onboard the GCP project to RSC. This can be done with the [GCP project](../gcp_project) Terraform module. Note,
creating archival locations requires the `CLOUD_NATIVE_ARCHIVAL` RSC feature with at least the `BASIC` permission group.
If customer-managed encryption keys are going to be used the `ENCRYPTION` permission group is required too.

When creating an archival location, the region where the snapshots will be stored needs to be specified. If the `region`
field is specified, the snapshots will be stored in the specific region. Otherwise, the snapshots will be stored in the
same region as the workload, source region. This affects the number of encryption keys required for customer-managed
encryption. For specific region, one key needs to be specified. For source region, one key per source region needs to be
specified. Regions not having a customer-managed key block will have its data encrypted with platform managed keys.

> [!NOTE]
> The module validates that the GCP project has been onboarded with the required features and permission groups.
> If the validation fails, Terraform will produce an error during the plan/apply phase.

> [!NOTE]
> When using customer-managed encryption keys, the module grants `roles/cloudkms.cryptoKeyEncrypterDecrypter` to the
> GCP Storage service for each customer managed key. 

> [!NOTE]
> The module does not create the KMS key rings and keys used with customer-managed encryption. They must exist before
> using this module.

## Usage

### Basic Usage without Customer-Managed Encryption Keys

```terraform
module "gcp_archival_location" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_archival_location"

  cloud_account_id = module.gcp_project.cloud_account_id
  bucket_prefix    = "my-bucket-prefix"
  name             = "my-archival-location"
  region           = "us-central1"
  storage_class    = "STANDARD"
}
```

### Specific Region with Customer-Managed Encryption Keys

```terraform
module "gcp_archival_location" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_archival_location"

  cloud_account_id = module.gcp_project.cloud_account_id
  bucket_prefix    = "my-bucket-prefix"
  name             = "my-archival-location"
  region           = "us-central1"
  storage_class    = "STANDARD"

  customer_managed_keys = [
    {
      name      = "my-key"
      ring_name = "my-key-ring"
      region    = "us-central1"
    },
  ]
}
```

### Source Region with Customer-Managed Encryption Keys

```terraform
module "gcp_archival_location" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_archival_location"

  cloud_account_id = module.gcp_project.cloud_account_id
  bucket_prefix    = "my-bucket-prefix"
  name             = "my-archival-location"
  storage_class    = "STANDARD"

  customer_managed_keys = [
    {
      name      = "my-key1"
      ring_name = "my-key-ring1"
      region    = "us-east1"
    },
    {
      name      = "my-key2"
      ring_name = "my-key-ring2"
      region    = "us-central1"
    },
    {
      name      = "my-key3"
      ring_name = "my-key-ring3"
      region    = "us-west1"
    },
  ]
}
```

## Examples

- [Basic Example](examples/basic)
- [Customer-Managed Keys Example](examples/with_customer_managed_keys)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.11.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=7.0.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=7.0.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.3.0 |

## Resources

| Name | Type |
|------|------|
| [google_kms_crypto_key_iam_member.key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [polaris_gcp_archival_location.archival_location](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/gcp_archival_location) | resource |
| [google_kms_crypto_key.key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [polaris_gcp_project.project](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/gcp_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_labels"></a> [bucket\_labels](#input\_bucket\_labels) | GCP bucket labels. Each label will be added to the GCP bucket created by RSC. | `map(string)` | `{}` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | GCP bucket prefix. The prefix cannot be longer than 19 characters. Note that `rubrik-` will always be prepended to the prefix. | `string` | n/a | yes |
| <a name="input_cloud_account_id"></a> [cloud\_account\_id](#input\_cloud\_account\_id) | RSC cloud account ID of the GCP project hosting the archival location. | `string` | n/a | yes |
| <a name="input_customer_managed_keys"></a> [customer\_managed\_keys](#input\_customer\_managed\_keys) | Customer managed storage encryption. Specify the regions and their respective encryption details. For other regions, data will be encrypted using platform managed keys. | <pre>set(object({<br/>    name      = string<br/>    region    = string<br/>    ring_name = string<br/>  }))</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the cloud archival location. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP region to store the snapshots in. If not specified, the snapshots will be stored in the same region as the workload. | `string` | `null` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | GCP bucket storage class. Possible values are `ARCHIVE`, `COLDLINE`, `NEARLINE`, `STANDARD` and `DURABLE_REDUCED_AVAILABILITY`. Default value is `STANDARD`. | `string` | `"STANDARD"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_archival_location_id"></a> [archival\_location\_id](#output\_archival\_location\_id) | RSC archival location ID. |
<!-- END_TF_DOCS -->
