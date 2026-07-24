# Azure DevOps organization onboarding

This example onboards a single Azure DevOps organization using Rubrik-hosted exocompute and RCV (Rubrik Cloud Vault)
auto-provisioned storage. It composes two modules: `azure_tenant` registers the Azure AD application for the Azure
DevOps use case, and `azure_devops` onboards the organization with Rubrik-hosted exocompute in the selected `region`
and RCV storage. Because Rubrik provides both exocompute and storage, no Azure subscription, exocompute cluster or
archival location has to be provisioned.

The example authenticates to Azure AD through the `azuread` provider, so the environment must be configured with
credentials that can register an application (e.g. via the Azure CLI or `ARM_*` environment variables).

The `onboarding_shell` input selects which onboarding script variant the apply runs against the Azure DevOps
organization. It defaults to `bash`, which requires `bash`, `curl`, `jq` and the Azure CLI (`az`) on the machine
running Terraform. On Windows, set `onboarding_shell = "powershell"` to run the PowerShell variant, which requires
Windows PowerShell and the Azure CLI. Either variant must be run signed in with `az login` as a Project Collection
Administrator in the organization; the script mints a short-lived Azure DevOps token from the `az login` session, so no
personal access token is needed.

> [!NOTE]
> This example runs the onboarding script inline during the apply, so Terraform must run on a host signed in as a
> Project Collection Administrator. To run the script out of band instead (for example in CI or under separation of
> duties), see the `azure_devops` module README.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.9.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_azure_devops"></a> [azure\_devops](#module\_azure\_devops) | ../.. | n/a |
| <a name="module_azure_tenant_devops"></a> [azure\_tenant\_devops](#module\_azure\_tenant\_devops) | ../../../azure_tenant | n/a |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_application_name_prefix"></a> [application\_name\_prefix](#input\_application\_name\_prefix) | Name prefix for the Azure AD applications. The cloud native protection and Azure DevOps applications append ` - CNP` and ` - DevOps` to it. | `string` | `"Rubrik Security Cloud"` | no |
| <a name="input_native_id"></a> [native\_id](#input\_native\_id) | Azure DevOps organization native ID, i.e. the organization name in the Azure DevOps URL (e.g. my-org from https://dev.azure.com/my-org). | `string` | n/a | yes |
| <a name="input_onboarding_shell"></a> [onboarding\_shell](#input\_onboarding\_shell) | Shell used to run the onboarding script during the apply. One of `bash` (default) or `powershell`. | `string` | `"bash"` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure region for the Rubrik-hosted exocompute. | `string` | `"eastus2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to Azure resources which support tags. | `map(string)` | <pre>{<br/>  "Example": "rubrik_hosted",<br/>  "Module": "azure_devops",<br/>  "Repository": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |
<!-- END_TF_DOCS -->
