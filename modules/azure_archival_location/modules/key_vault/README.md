# Key Vault Module

This module creates an Azure key vault and a key for use with customer-managed encryption in the
[azure_archival_location](../..) module. The key vault is created with Azure RBAC authorization enabled, which is the
authorization model required by the `azure_archival_location` module. Its primary use case is to provide encryption keys
for the `azure_archival_location` examples.

The module does not provide any form of lifecycle protection to prevent accidental deletion of the key vault or key.

> [!WARNING]
> When Terraform destroys the key, any data previously encrypted with it becomes irrecoverable. It is strongly
> recommended that you add lifecycle hooks to prevent accidental destruction.

Because the key vault uses RBAC authorization, the credentials running Terraform need the `Key Vault Crypto Officer`
role on the vault to create the key. By default the module grants this role to the current credentials and waits for
the assignment to propagate. This requires permission to create role assignments. If the role has already been granted
out of band, set `grant_creator_key_permissions` to `false`.

## Usage

### Basic Usage

```terraform
module "key_vault" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_archival_location/modules/key_vault"

  key_vault_name      = "my-key-vault"
  key_name            = "my-key"
  resource_group_name = "my-resource-group"
  location            = "eastus2"
}
```

### With a Basic form of Lifecycle Protection

```terraform
module "key_vault" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_archival_location/modules/key_vault"

  key_vault_name      = "my-key-vault"
  key_name            = "my-key"
  resource_group_name = "my-resource-group"
  location            = "eastus2"
}

resource "null_resource" "prevent_destroy" {
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    module.key_vault,
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_key_vault.key_vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_key.key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key) | resource |
| [azurerm_role_assignment.creator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [time_sleep.role_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_grant_creator_key_permissions"></a> [grant\_creator\_key\_permissions](#input\_grant\_creator\_key\_permissions) | Whether to grant the current Azure credentials the `Key Vault Crypto Officer` role on the key vault so that the key can be created. Requires permission to create role assignments. Set to false if the role has been granted out of band. | `bool` | `true` | no |
| <a name="input_key_name"></a> [key\_name](#input\_key\_name) | The name of the key to create in the key vault. | `string` | n/a | yes |
| <a name="input_key_opts"></a> [key\_opts](#input\_key\_opts) | The permitted operations for the key. Archival encryption requires at least `wrapKey` and `unwrapKey`. | `list(string)` | <pre>[<br/>  "decrypt",<br/>  "encrypt",<br/>  "sign",<br/>  "unwrapKey",<br/>  "verify",<br/>  "wrapKey"<br/>]</pre> | no |
| <a name="input_key_size"></a> [key\_size](#input\_key\_size) | The size of the key in bits. Only applies to RSA keys. Default value is 2048. | `number` | `2048` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | The type of key to create. Possible values are `RSA`, `RSA-HSM`, `EC` and `EC-HSM`. Default value is `RSA`. | `string` | `"RSA"` | no |
| <a name="input_key_vault_name"></a> [key\_vault\_name](#input\_key\_vault\_name) | The name of the key vault to create. Key vault names must be globally unique. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region in which to create the key vault. | `string` | n/a | yes |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Whether purge protection is enabled for the key vault. Once enabled it cannot be disabled. | `bool` | `false` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the resource group in which to create the key vault. The resource group must already exist. | `string` | n/a | yes |
| <a name="input_role_propagation_delay"></a> [role\_propagation\_delay](#input\_role\_propagation\_delay) | How long to wait for the `Key Vault Crypto Officer` role assignment to propagate before creating the key. Only applies when grant\_creator\_key\_permissions is true. | `string` | `"60s"` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The key vault SKU. Possible values are `standard` and `premium`. Default value is `standard`. | `string` | `"standard"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the key vault and key. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | The key vault key ID. |
| <a name="output_key_name"></a> [key\_name](#output\_key\_name) | The key vault key name. |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | The key vault ID. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | The key vault name. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | The name of the resource group containing the key vault. |
<!-- END_TF_DOCS -->
