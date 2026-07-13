# Exocompute Example

The configuration in this directory demonstrates how to configure exocompute for an Azure subscription onboarded to RSC.
The configuration performs the following steps:

1. Create and onboard the Azure application/tenant to RSC.
2. Create the resource group required by the cloud native protection and exocompute features.
3. Onboard the Azure subscription to RSC with the cloud native protection and exocompute features.
4. Configure exocompute for the subscription in the `eastus2` region.

The exocompute cluster is deployed into an existing subnet, whose ID is supplied through the required `subnet_id` input.

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
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.99.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.99.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_azure_exocompute"></a> [azure\_exocompute](#module\_azure\_exocompute) | ../.. | n/a |
| <a name="module_azure_subscription"></a> [azure\_subscription](#module\_azure\_subscription) | ../../../azure_subscription | n/a |
| <a name="module_azure_tenant"></a> [azure\_tenant](#module\_azure\_tenant) | ../../../azure_tenant | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_region"></a> [region](#input\_region) | Azure region for the subscription, resource group and exocompute cluster. | `string` | `"eastus2"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the cloud native protection and exocompute features. | `string` | `"rubrik-azure-exocompute-example"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Azure subnet ID for the exocompute cluster. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure resources which support tags. | `map(string)` | <pre>{<br/>  "Example": "basic",<br/>  "Module": "azure_exocompute",<br/>  "Repository": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
