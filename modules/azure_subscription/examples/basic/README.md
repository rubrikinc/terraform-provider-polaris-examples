# Azure subscription onboarding

The configuration in this directory onboards an Azure subscription to RSC. It registers a new Azure AD application,
creates the resource groups and user assigned identities required by the enabled features, and onboards the
subscription with the corresponding custom roles.

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
| [azurerm_user_assigned_identity.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_features"></a> [features](#input\_features) | n/a | <pre>map(object({<br/>    permission_groups = set(string)<br/><br/>    resource_group = optional(object({<br/>      name = string<br/>      tags = optional(map(string), {<br/>        Example    = "basic"<br/>        Module     = "azure_subscription"<br/>        Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>      })<br/>    }))<br/><br/>    user_assigned_identity = optional(object({<br/>      name                = string<br/>      resource_group_name = string<br/>      tags = optional(map(string), {<br/>        Example    = "basic"<br/>        Module     = "azure_subscription"<br/>        Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>      })<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure region for the subscription, resource groups and user assigned identities. | `string` | `"eastus2"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
