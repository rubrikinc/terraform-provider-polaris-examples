# Azure Tenant Module

This module registers an Azure AD application and service principal with RSC. By default it creates a new application
and service principal. Alternatively, an existing application can be passed in via `app_id` and `app_secret`, in which
case the module looks up the service principal automatically and skips creating any Azure AD resources.

The tenant's initial Azure AD domain is discovered automatically; if more than one domain is present the first one is
used and a warning is emitted.

## Usage

### Create a new application

```terraform
module "azure_tenant" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//azure-devops-support/modules/azure_tenant"
}
```

### Use an existing application

```terraform
module "azure_tenant" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//azure-devops-support/modules/azure_tenant"

  app_id     = "<application-client-id>"
  app_secret = "<client-secret>"
}
```

## Examples

- [Basic Example](examples/basic)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >=2.48.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.9.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azuread_application.application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.password](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.service_principal](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| polaris_azure_service_principal.service_principal | resource |
| [azuread_application.application](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/application) | data source |
| [azuread_client_config.current](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/client_config) | data source |
| [azuread_domains.aad_domains](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/domains) | data source |
| [azuread_service_principal.service_principal](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/service_principal) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Application (client) ID of an existing Azure AD application. When given together with `app_secret`, the module skips creating a new application and service principal and registers the existing one with RSC. When not given, a new application is created. | `string` | `null` | no |
| <a name="input_app_secret"></a> [app\_secret](#input\_app\_secret) | Client secret of the existing Azure AD application. Required when `app_id` is set. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Display name for the Azure AD application. Cannot be set together with `app_id`. When neither `app_id` nor `display_name` is specified, the application is created with the default name 'Rubrik Security Cloud - Azure Protection'. | `string` | `null` | no |
| <a name="input_use_case"></a> [use\_case](#input\_use\_case) | What the service principal is registered for. One of `CLOUD_NATIVE_PROTECTION` (default) or `AZURE_DEVOPS`. The credentials are stored in a separate location per use case, so a tenant can have one service principal per use case. | `string` | `"CLOUD_NATIVE_PROTECTION"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | Application (client) ID of the Azure AD application. |
| <a name="output_app_name"></a> [app\_name](#output\_app\_name) | Display name of the Azure AD application. |
| <a name="output_object_id"></a> [object\_id](#output\_object\_id) | Object ID of the Azure AD service principal. This is the same ID used as principal\_id in Azure RBAC role assignments. |
| <a name="output_tenant_domain"></a> [tenant\_domain](#output\_tenant\_domain) | Azure AD tenant primary domain. |
| <a name="output_tenant_id"></a> [tenant\_id](#output\_tenant\_id) | Azure AD tenant ID. |
<!-- END_TF_DOCS -->
