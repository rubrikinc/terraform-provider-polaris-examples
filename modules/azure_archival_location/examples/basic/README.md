# Archival Location Example

The configuration in this directory demonstrates how to create a basic RSC archival location for Azure cloud native
workloads. The configuration performs the following steps:

1. Create and onboard the Azure application/tenant to RSC.
2. Create the resource group required by the cloud native archival feature.
3. Onboard the Azure subscription to RSC with the cloud native archival feature.
4. Create an RSC archival location in the `eastus2` region.

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
| ---- | ------- |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >=2.48.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=4.0.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=4.0.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_azure_archival_location"></a> [azure\_archival\_location](#module\_azure\_archival\_location) | ../.. | n/a |
| <a name="module_azure_subscription"></a> [azure\_subscription](#module\_azure\_subscription) | ../../../azure_subscription | n/a |
| <a name="module_azure_tenant"></a> [azure\_tenant](#module\_azure\_tenant) | ../../../azure_tenant | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_name"></a> [name](#input\_name) | Name of the RSC archival location. | `string` | `"archival-location"` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure region for the subscription, resource group and archival location. | `string` | `"eastus2"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the cloud native archival feature. | `string` | `"rubrik-azure-archival-example"` | no |
| <a name="input_storage_account_name_prefix"></a> [storage\_account\_name\_prefix](#input\_storage\_account\_name\_prefix) | Azure storage account name prefix. Can only consist of lower case letters and numbers. | `string` | `"rubrikarchival"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure resources which support tags. | `map(string)` | <pre>{<br/>  "Example": "basic",<br/>  "Module": "azure_archival_location",<br/>  "Repository": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
