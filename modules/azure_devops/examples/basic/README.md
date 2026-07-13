# Azure DevOps organization onboarding

This example onboards a single Azure DevOps organization using customer-hosted exocompute and a customer-managed
archival location, both provisioned in a customer Azure subscription. It composes five modules: `azure_tenant` registers
the Azure AD applications (once for the cloud native protection use case, once for the Azure DevOps use case, since
credentials are stored separately per use case), `azure_subscription` onboards the subscription with the `EXOCOMPUTE`
and `CLOUD_NATIVE_ARCHIVAL` features, `azure_exocompute` configures the exocompute cluster, `azure_archival_location`
creates the archival location, and `azure_devops` onboards the organization against them. The organization's
`exocompute_host_id` is the subscription's cloud account ID and its `archival_location_id` is the archival location ID,
which sequences subscription onboarding, exocompute configuration and archival creation before the organization is
onboarded.

The example authenticates to Azure AD through the `azuread` provider, so the environment must be configured with
credentials that can register an application (e.g. via the Azure CLI or `ARM_*` environment variables). The exocompute
cluster is deployed into an existing subnet, whose ID is supplied through the `subnet_id` input.

The `run_onboarding_script` input selects which onboarding script variant the apply runs against the Azure DevOps
organization. It defaults to `bash`, which requires `bash`, `curl`, `jq` and the Azure CLI (`az`) on the machine
running Terraform. On Windows, set `run_onboarding_script = "powershell"` to run the PowerShell variant, which requires
Windows PowerShell and the Azure CLI. Either variant must be run signed in with `az login` as a Project Collection
Administrator in the organization; the script mints a short-lived Azure DevOps token from the `az login` session, so no
personal access token is needed.

> [!NOTE]
> To run the onboarding script out of band instead, leave `run_onboarding_script` unset (`null`) and use the module's
> `onboarding_bash_script` or `onboarding_powershell_script` output.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.80.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_azure_archival_location"></a> [azure\_archival\_location](#module\_azure\_archival\_location) | ../../../azure_archival_location | n/a |
| <a name="module_azure_devops"></a> [azure\_devops](#module\_azure\_devops) | ../.. | n/a |
| <a name="module_azure_exocompute"></a> [azure\_exocompute](#module\_azure\_exocompute) | ../../../azure_exocompute | n/a |
| <a name="module_azure_subscription"></a> [azure\_subscription](#module\_azure\_subscription) | ../../../azure_subscription | n/a |
| <a name="module_azure_tenant_cnp"></a> [azure\_tenant\_cnp](#module\_azure\_tenant\_cnp) | ../../../azure_tenant | n/a |
| <a name="module_azure_tenant_devops"></a> [azure\_tenant\_devops](#module\_azure\_tenant\_devops) | ../../../azure_tenant | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_application_name_prefix"></a> [application\_name\_prefix](#input\_application\_name\_prefix) | Name prefix for the Azure AD applications. The cloud native protection and Azure DevOps applications append ` - CNP` and ` - DevOps` to it. | `string` | `"Rubrik Security Cloud"` | no |
| <a name="input_archival_name"></a> [archival\_name](#input\_archival\_name) | Name of the RSC archival location. | `string` | `"archival-location"` | no |
| <a name="input_native_id"></a> [native\_id](#input\_native\_id) | Azure DevOps organization native ID, i.e. the organization name in the Azure DevOps URL (e.g. my-org from https://dev.azure.com/my-org). | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure region for the subscription, resource group, exocompute cluster and archival location. | `string` | `"eastus2"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group name for the cloud native archival and exocompute features. | `string` | `"rubrik-azure-devops-example"` | no |
| <a name="input_run_onboarding_script"></a> [run\_onboarding\_script](#input\_run\_onboarding\_script) | Onboarding script variant to run during the apply. One of `bash` (default) or `powershell`. Set to `powershell` on Windows. | `string` | `"bash"` | no |
| <a name="input_storage_account_name_prefix"></a> [storage\_account\_name\_prefix](#input\_storage\_account\_name\_prefix) | Azure storage account name prefix. Can only consist of lower case letters and numbers. | `string` | `"rubrikarchival"` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Azure subnet ID for the exocompute cluster. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure resources which support tags. | `map(string)` | <pre>{<br/>  "Example": "basic",<br/>  "Module": "azure_devops",<br/>  "Repository": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
