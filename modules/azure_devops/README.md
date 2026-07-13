# Azure DevOps Module

This module onboards an Azure DevOps organization to RSC. It generates the onboarding script and onboards the
organization for the selected set of RSC features. The service principal is not registered here: register it first with
the `azure_tenant` module using `use_case = "AZURE_DEVOPS"` and pass its `tenant_domain` output into this module.

> [!IMPORTANT]
> Onboarding an organization requires the generated onboarding script to be run against the Azure DevOps organization.
> The provider does not run the script, it only generates it. The script provisions the Rubrik service principal and its
> permission groups in the organization, so it must run before the organization is onboarded. It is exposed through the
> `onboarding_bash_script` and `onboarding_powershell_script` outputs, or it can be run automatically during the apply
> by setting `run_onboarding_script` to `bash` or `powershell`.

> [!IMPORTANT]
> Running the onboarding script requires being signed in with the Azure CLI as a user who is a Project Collection
> Administrator in the target organization (`az login`, or `az login --allow-no-subscriptions --tenant
> <ENTRA_TENANT_ID>` for a tenant with no Azure subscription). The script mints a short-lived Azure DevOps token from
> the `az login` session; no personal access token is required. The two script variants have different prerequisites:
> - The bash script (`run_onboarding_script = "bash"`, or the `onboarding_bash_script` output) needs `bash`, `curl`,
>   `jq` and the Azure CLI.
> - The PowerShell script (`run_onboarding_script = "powershell"`, or the `onboarding_powershell_script` output) needs
>   Windows PowerShell 5.1+ and the Azure CLI only. The automated run uses `powershell`; run the output out of band to
>   use `pwsh`.

> [!WARNING]
> Per-organization provisioning is not idempotent. If a previous run partially created the permission groups or added
> the service principal, re-running fails with an HTTP 409 Conflict. Remove the partially-created groups and the
> service-principal entitlement from the organization's Settings UI before re-running.

## Usage

```terraform
# Register the service principal for the Azure DevOps use case.
module "azure_tenant" {
  source   = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_tenant"
  use_case = "AZURE_DEVOPS"
}

module "azure_devops" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_devops"

  native_id     = "my-org"
  tenant_domain = module.azure_tenant.tenant_domain

  exocompute_host_type = "RUBRIK_HOST"
  exocompute_region    = "eastus"
  storage_type         = "RCV"

  features = {
    AZURE_DEVOPS_PROTECTION            = {}
    AZURE_DEVOPS_REPOSITORY_PROTECTION = {}
  }
}
```

## Features and permission groups

Each entry in `features` enables an RSC feature and, optionally, a subset of that feature's permission groups. An empty
set (`permission_groups = []`) enables all of the feature's groups. The available groups per feature are:

| Feature | Permission groups |
| ------- | ----------------- |
| `AZURE_DEVOPS_PROTECTION` | `BASIC` |
| `AZURE_DEVOPS_REPOSITORY_PROTECTION` | `BASIC`, `RECOVERY` |
| `AZURE_DEVOPS_DEVELOPER_COLLABORATION_PROTECTION` | `BASIC`, `RECOVERY` |

## Examples

- [Basic Example](examples/basic)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.2.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.9.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_null"></a> [null](#provider\_null) | >=3.2.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [null_resource.onboard](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| polaris_azure_devops_organization.org | resource |
| polaris_azure_devops_script.onboard | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_archival_location_id"></a> [archival\_location\_id](#input\_archival\_location\_id) | Archival location ID for backups. Required when `storage_type` is `BYOS`. | `string` | `null` | no |
| <a name="input_cloud_type"></a> [cloud\_type](#input\_cloud\_type) | Azure cloud type. One of `PUBLIC` (default), `CHINA` or `USGOV`. | `string` | `"PUBLIC"` | no |
| <a name="input_delete_snapshots_on_destroy"></a> [delete\_snapshots\_on\_destroy](#input\_delete\_snapshots\_on\_destroy) | Delete the organization's snapshots when the resource is destroyed. | `bool` | `false` | no |
| <a name="input_exocompute_host_id"></a> [exocompute\_host\_id](#input\_exocompute\_host\_id) | RSC cloud account ID providing exocompute. Required when `exocompute_host_type` is `CUSTOMER_HOST`. | `string` | `null` | no |
| <a name="input_exocompute_host_type"></a> [exocompute\_host\_type](#input\_exocompute\_host\_type) | Type of exocompute host. One of `RUBRIK_HOST` (requires `exocompute_region`) or `CUSTOMER_HOST` (requires `exocompute_host_id`). | `string` | `"RUBRIK_HOST"` | no |
| <a name="input_exocompute_region"></a> [exocompute\_region](#input\_exocompute\_region) | Azure region for Rubrik-hosted exocompute (e.g. `eastus`). Required when `exocompute_host_type` is `RUBRIK_HOST`. | `string` | `null` | no |
| <a name="input_features"></a> [features](#input\_features) | RSC features with permission groups. Possible features are: AZURE\_DEVOPS\_PROTECTION, AZURE\_DEVOPS\_REPOSITORY\_PROTECTION and AZURE\_DEVOPS\_DEVELOPER\_COLLABORATION\_PROTECTION. Omitting a feature's permission groups, or setting them to an empty set, enables all groups for the feature. | <pre>map(object({<br/>    permission_groups = optional(set(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_native_id"></a> [native\_id](#input\_native\_id) | Azure DevOps organization native identifier, i.e. the organization name visible in the Azure DevOps URL (e.g. `my-org` from https://dev.azure.com/my-org). | `string` | n/a | yes |
| <a name="input_run_onboarding_script"></a> [run\_onboarding\_script](#input\_run\_onboarding\_script) | Run the generated onboarding script during the apply. One of `bash` or `powershell`, selecting which script variant to run. When `null` (default), the script is not run. See the module README for prerequisites and how to run the script out of band. | `string` | `null` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Type of backup storage. One of `RCV` (Rubrik Cloud Vault, auto-provisioned) or `BYOS` (Bring Your Own Storage, requires `archival_location_id`). | `string` | `"RCV"` | no |
| <a name="input_tenant_domain"></a> [tenant\_domain](#input\_tenant\_domain) | Azure AD tenant primary domain (e.g. `mydomain.onmicrosoft.com`). | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_onboarding_bash_script"></a> [onboarding\_bash\_script](#output\_onboarding\_bash\_script) | Bash onboarding script to run against the Azure DevOps organization out of band. |
| <a name="output_onboarding_powershell_script"></a> [onboarding\_powershell\_script](#output\_onboarding\_powershell\_script) | PowerShell onboarding script to run against the Azure DevOps organization out of band. |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | RSC organization ID (UUID) for the onboarded Azure DevOps organization. |
<!-- END_TF_DOCS -->
