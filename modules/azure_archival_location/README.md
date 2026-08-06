# Azure Archival Location Module

This module manages an RSC archival location for storing snapshots of Azure cloud native workloads. The module
optionally configures customer-managed encryption keys for enhanced security control. To create an Azure archival
location, you first need to onboard the Azure subscription to RSC. This can be done with the
[azure_subscription](../azure_subscription) Terraform module. Note, creating archival locations requires the
`CLOUD_NATIVE_ARCHIVAL` RSC feature. If customer-managed encryption keys are going to be used the
`CLOUD_NATIVE_ARCHIVAL_ENCRYPTION` feature with a user assigned identity is required too.

When creating an archival location, the region where the snapshots will be stored can be specified. If the
`storage_account_region` field is specified, the snapshots will be stored in that specific region. Otherwise, the
snapshots will be stored in the same region as the workload, the source region. This affects the number of encryption
keys required for customer-managed encryption. For a specific region, one key needs to be specified. For source region,
one key per source region needs to be specified. Regions not having a customer-managed key block will have its data
encrypted with platform managed keys.

> [!NOTE]
> Only key vaults using Azure RBAC authorization are supported. When onboarding the `CLOUD_NATIVE_ARCHIVAL_ENCRYPTION`
> feature, RSC grants the user assigned identity access to the RBAC key vaults in the subscription. Access policy
> (legacy) key vaults are not granted access by RSC and are not supported by this module. The module reads each key
> vault and fails if it does not use RBAC authorization.

> [!NOTE]
> The module does not create the key vaults and keys used with customer-managed encryption. They must exist before using
> this module. The [key_vault](modules/key_vault) submodule can be used to create them.

## Usage

### Basic Usage without Customer-Managed Encryption Keys

```terraform
module "azure_archival_location" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_archival_location"

  cloud_account_id            = module.azure_subscription.cloud_account_id
  name                        = "my-archival-location"
  storage_account_name_prefix = "myarchival"
  storage_account_region      = "eastus2"
  storage_tier                = "COOL"
}
```

### Specific Region with Customer-Managed Encryption Keys

```terraform
module "azure_archival_location" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_archival_location"

  cloud_account_id            = module.azure_subscription.cloud_account_id
  name                        = "my-archival-location"
  storage_account_name_prefix = "myarchival"
  storage_account_region      = "eastus2"
  storage_tier                = "COOL"

  customer_managed_keys = [
    {
      name                = "my-key"
      region              = "eastus2"
      vault_name          = "my-key-vault"
      resource_group_name = "my-resource-group"
    },
  ]
}
```

### Source Region with Customer-Managed Encryption Keys

```terraform
module "azure_archival_location" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_archival_location"

  cloud_account_id            = module.azure_subscription.cloud_account_id
  name                        = "my-archival-location"
  storage_account_name_prefix = "myarchival"
  storage_tier                = "COOL"

  customer_managed_keys = [
    {
      name                = "my-key1"
      region              = "eastus2"
      vault_name          = "my-key-vault1"
      resource_group_name = "my-resource-group"
    },
    {
      name                = "my-key2"
      region              = "westus2"
      vault_name          = "my-key-vault2"
      resource_group_name = "my-resource-group"
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
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.0.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.7.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [polaris_azure_archival_location.archival_location](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_archival_location) | resource |
| [azurerm_key_vault.vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_key.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloud_account_id"></a> [cloud\_account\_id](#input\_cloud\_account\_id) | RSC cloud account ID of the Azure subscription hosting the archival location. | `string` | n/a | yes |
| <a name="input_customer_managed_keys"></a> [customer\_managed\_keys](#input\_customer\_managed\_keys) | Customer managed storage encryption. Specify the regions and their respective encryption details. For other regions, data will be encrypted using platform managed keys. Only key vaults using Azure RBAC authorization are supported. | <pre>set(object({<br/>    name                = string<br/>    region              = string<br/>    vault_name          = string<br/>    resource_group_name = string<br/>  }))</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the cloud archival location. | `string` | n/a | yes |
| <a name="input_network_access_type"></a> [network\_access\_type](#input\_network\_access\_type) | Azure storage account network access type. Possible values are `PRIVATE`, `PUBLIC` and `SELECTED_NETWORKS`. If not specified, RSC decides the default. | `string` | `null` | no |
| <a name="input_redundancy"></a> [redundancy](#input\_redundancy) | Azure storage redundancy. Possible values are `GRS`, `GZRS`, `LRS`, `RA_GRS`, `RA_GZRS` and `ZRS`. Default value is `LRS`. | `string` | `"LRS"` | no |
| <a name="input_storage_account_name_prefix"></a> [storage\_account\_name\_prefix](#input\_storage\_account\_name\_prefix) | Azure storage account name prefix. When `storage_account_region` is not specified (`SOURCE_REGION`), the prefix cannot be longer than 16 characters. When `storage_account_region` is specified (`SPECIFIC_REGION`), the prefix cannot be longer than 24 characters. The prefix can only consist of lower case letters and numbers. | `string` | n/a | yes |
| <a name="input_storage_account_region"></a> [storage\_account\_region](#input\_storage\_account\_region) | Azure region to store the snapshots in. If not specified, the snapshots will be stored in the same region as the workload. | `string` | `null` | no |
| <a name="input_storage_account_tags"></a> [storage\_account\_tags](#input\_storage\_account\_tags) | Azure storage account tags. Each tag will be added to the storage account created by RSC. | `map(string)` | `{}` | no |
| <a name="input_storage_tier"></a> [storage\_tier](#input\_storage\_tier) | Azure storage tier. Possible values are `COOL` and `HOT`. Default value is `COOL`. | `string` | `"COOL"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_archival_location_id"></a> [archival\_location\_id](#output\_archival\_location\_id) | RSC archival location ID. |
<!-- END_TF_DOCS -->
