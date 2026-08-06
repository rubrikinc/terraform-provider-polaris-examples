# Azure Subscription Module

This module onboards an Azure subscription to RSC with a configurable set of features. For each feature it creates the
Azure custom roles required by RSC — a subscription scoped role, and, for features that operate on a resource group, a
resource group scoped role — and assigns them to the service principal used by RSC.

Resource groups and user assigned identities are not created by this module; they are looked up by name and must already
exist. A feature that doesn't specify its own resource group or user assigned identity falls back to the configured
default. Features that RSC doesn't associate with a resource group or user assigned identity receive neither, even when
they are specified.

Setting `exocompute_host_id` registers the subscription as a shared exocompute application account that uses the
exocompute resources deployed by the host subscription. In that setup the application account does not need the
`EXOCOMPUTE` feature itself — only the host subscription does.

## Usage

The resource group referenced below must already exist in the subscription. See the `basic` example for a complete
setup that creates the application, resource groups and user assigned identities alongside the subscription onboarding.

```terraform
module "azure_subscription" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_subscription"

  principal_id  = "<service-principal-object-id>"
  tenant_domain = "my-domain.onmicrosoft.com"

  default_resource_group = {
    name = "rubrik-rg"
  }

  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    }
  }

  regions = [
    "eastus2",
    "westus2"
  ]
}
```

## Examples

- [Basic Example](examples/basic)
- [Shared Exocompute Example](examples/shared_exocompute)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.99.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.7.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.99.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.7.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_role_assignment.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_role_definition.subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [polaris_azure_exocompute.exocompute](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_exocompute) | resource |
| [polaris_azure_subscription.subscription](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_subscription) | resource |
| [time_sleep.wait_for_rsc](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [azurerm_resource_group.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_resource_group.feature](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_user_assigned_identity.default](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [azurerm_user_assigned_identity.feature](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |
| [polaris_azure_permissions.feature](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/azure_permissions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_default_resource_group"></a> [default\_resource\_group](#input\_default\_resource\_group) | Default Azure resource group. The default is used when a feature specific one isn't specified and it is required by RSC. | <pre>object({<br/>    name = string<br/>    tags = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_default_user_assigned_identity"></a> [default\_user\_assigned\_identity](#input\_default\_user\_assigned\_identity) | Default Azure user assigned identity. The default is used when a feature specific one isn't specified and it is required by RSC. | <pre>object({<br/>    name                = string<br/>    resource_group_name = string<br/>    tags                = optional(map(string))<br/>  })</pre> | `null` | no |
| <a name="input_exocompute_group_id"></a> [exocompute\_group\_id](#input\_exocompute\_group\_id) | Object ID of the Entra ID group for Entra ID authentication in Exocompute AKS clusters. Only required for Exocompute host accounts (subscriptions with the EXOCOMPUTE feature), not by application accounts. This is a tenant-level setting shared across all subscriptions in the tenant. | `string` | `null` | no |
| <a name="input_exocompute_host_id"></a> [exocompute\_host\_id](#input\_exocompute\_host\_id) | RSC cloud account ID (UUID) of the Azure subscription hosting exocompute. When set, this subscription is registered as a shared exocompute application account, using the exocompute resources deployed by the host subscription. | `string` | `null` | no |
| <a name="input_features"></a> [features](#input\_features) | RSC features with permission groups, resource groups and user assigned identities. | <pre>map(object({<br/>    permission_groups = set(string)<br/>    resource_group = optional(object({<br/>      name = string<br/>      tags = optional(map(string))<br/>    }))<br/>    user_assigned_identity = optional(object({<br/>      name                = string<br/>      resource_group_name = string<br/>      tags                = optional(map(string))<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_principal_id"></a> [principal\_id](#input\_principal\_id) | Object ID of the Azure AD service principal used by RSC. This is the same ID used as principal\_id in Azure RBAC role assignments. | `string` | n/a | yes |
| <a name="input_regions"></a> [regions](#input\_regions) | Azure regions to protect with RSC. | `set(string)` | n/a | yes |
| <a name="input_role_prefix"></a> [role\_prefix](#input\_role\_prefix) | Prefix for Azure role names created by RSC. Defaults to *Rubrik Security Cloud*. | `string` | `"Rubrik Security Cloud"` | no |
| <a name="input_tenant_domain"></a> [tenant\_domain](#input\_tenant\_domain) | Azure tenant domain. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloud_account_id"></a> [cloud\_account\_id](#output\_cloud\_account\_id) | RSC cloud account ID of the onboarded Azure subscription. |
<!-- END_TF_DOCS -->
