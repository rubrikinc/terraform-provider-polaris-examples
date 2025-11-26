# Crypto Key Module

This module manages a Google Cloud KMS (Key Management Service) key ring and crypto key for encryption and decryption
of data. The module will use existing resources if they are found, or create new ones if they don't exist. Its primary
use case is to manage crypto keys for the `gcp_archival_location` tests. The module configures automatic key rotation
for newly created keys. The module does not provide any form of lifecycle protection to prevent accidental deletion of
the encryption keys.

> [!WARNING]
> When Terraform destroys the crypto key, it also destroys all versions of the key, and any data previously encrypted
> with these keys will be irrecoverable. Note that this only applies if the module created the resources; if the module
> is using existing resources, destroying the module will not delete them. For this reason, it is strongly recommended
> that you add lifecycle hooks to the resource to prevent accidental destruction.

## Usage

### Basic Usage

```terraform
module "crypto_key" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_archival_location/modules/crypto_key"

  key_name      = "my-key"
  key_ring_name = "my-key-ring"
  region        = "us-central1"
}
```

### With a Basic form of Lifecycle Protection

```terraform
module "crypto_key" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_archival_location/modules/crypto_key"

  key_name      = "my-key"
  key_ring_name = "my-key-ring"
  region        = "us-central1"
}

resource "null_resource" "prevent_destroy" {
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    module.crypto_key,
  ]
}
```

> [!NOTE]
> If a key ring or crypto key with the specified names already exists in the region, the module will use the existing
> resources instead of creating new ones. This allows for idempotent deployments.

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
| [google_kms_crypto_key.key](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_kms_crypto_keys.keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_keys) | data source |
| [google_kms_key_rings.key_rings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_rings) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the KMS crypto key. If a crypto key with this name already exists in the key ring, it will be used; otherwise, a new one will be created. | `string` | n/a | yes |
| <a name="input_key_ring_name"></a> [key\_ring\_name](#input\_key\_ring\_name) | The name of the KMS key ring that will contain the crypto key. If a key ring with this name already exists in the region, it will be used; otherwise, a new one will be created. | `string` | n/a | yes |
| <a name="input_key_rotation_period"></a> [key\_rotation\_period](#input\_key\_rotation\_period) | The rotation period for the crypto key in seconds. The key will be automatically rotated at this interval. Only applies when creating a new crypto key. Default is 2592000s (30 days). | `string` | `"2592000s"` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to the crypto key. Only applies when creating a new crypto key. | `map(string)` | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | The GCP region where the key ring and crypto key will be created or looked up. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The GCP crypto key ID. |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | The GCP crypto key name. |
| <a name="output_key_ring_name"></a> [key\_ring\_name](#output\_key\_ring\_name) | The GCP key ring name. |
| <a name="output_key_rotation_period"></a> [key\_rotation\_period](#output\_key\_rotation\_period) | The GCP crypto key rotation period. |
<!-- END_TF_DOCS -->
