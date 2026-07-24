# Azure subscription onboarding with shared exocompute

The configuration in this directory onboards an Azure subscription to RSC as a shared exocompute application account. It
registers a new Azure AD application, creates the resource group required by the enabled features, and onboards the
subscription pointing it at a host subscription that provides the exocompute resources.

The host subscription is identified by its RSC cloud account ID via `exocompute_host_id`. The application account uses
the host's exocompute resources, so it does not need the `EXOCOMPUTE` feature itself.

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
| <a name="module_azure_subscription"></a> [azure\_subscription](#module\_azure\_subscription) | ../.. | n/a |
| <a name="module_azure_tenant"></a> [azure\_tenant](#module\_azure\_tenant) | ../../../azure_tenant | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_exocompute_host_id"></a> [exocompute\_host\_id](#input\_exocompute\_host\_id) | RSC cloud account ID (UUID) of the Azure subscription hosting exocompute. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure region for the subscription and resource group. | `string` | `"eastus2"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the cloud native protection feature. | `string` | `"rubrik-azure-subscription-example"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure resources which support tags. | `map(string)` | <pre>{<br/>  "Example": "shared_exocompute",<br/>  "Module": "azure_subscription",<br/>  "Repository": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
