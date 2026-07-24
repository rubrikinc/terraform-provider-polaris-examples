# Azure DevOps Module

This module onboards an Azure DevOps organization to RSC. It generates the onboarding script and onboards the
organization for the selected set of RSC features. The service principal is not registered here: register it first with
the `azure_tenant` module using `use_case = "AZURE_DEVOPS"` and pass its `tenant_domain` output into this module.

> [!IMPORTANT]
> The onboarding script provisions the Rubrik service principal and its permission groups in the Azure DevOps
> organization and must run before the organization is onboarded. This module runs it for you during the apply: set
> `onboarding_shell` to `bash` (default) or `powershell` to select the shell. The organization resource depends on the
> run, so the ordering is handled automatically.

> [!IMPORTANT]
> The script runs on the same host as `terraform apply`, which must be signed in with the Azure CLI as a user who is a
> Project Collection Administrator in the target organization (`az login`, or `az login --allow-no-subscriptions
> --tenant <ENTRA_TENANT_ID>` for a tenant with no Azure subscription). The script mints a short-lived Azure DevOps
> token from the `az login` session; no personal access token is required. The two script variants have different
> prerequisites:
> - The bash script (`onboarding_shell = "bash"`) needs `bash`, `curl`, `jq` and the Azure CLI.
> - The PowerShell script (`onboarding_shell = "powershell"`) needs Windows PowerShell 5.1+ and the Azure CLI only.
>   The module invokes it with `powershell`; to use `pwsh`, run the script out of band.

> [!NOTE]
> When the identity running Terraform is not the organization's Project Collection Administrator (for example in CI, or
> under separation of duties), run the script out of band instead of relying on this module's inline run: generate it
> with the `polaris_azure_devops_script` data source, run it against the organization yourself, and onboard the
> organization only after it has run.

## Usage

```terraform
# Register the service principal for the Azure DevOps use case.
module "azure_tenant" {
  source   = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_tenant"
  use_case = "AZURE_DEVOPS"
}

module "azure_devops" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_devops"

  # Organization settings.
  native_id     = "my-org"
  tenant_domain = module.azure_tenant.tenant_domain

  features = {
    AZURE_DEVOPS_REPOSITORY_PROTECTION = {
      permission_groups = ["BASIC"]
    }
  }

  # Exocompute settings.
  exocompute_host_type = "RUBRIK_HOST"
  exocompute_region    = "eastus"

  # Storage settings.
  storage_type         = "RCV"
}
```

## Features and permission groups

Each entry in `features` enables an RSC feature and the permission groups to grant for it. At least one permission group
is required per feature. The available groups per feature are:

| Feature | Permission groups |
| ------- | ----------------- |
| `AZURE_DEVOPS_REPOSITORY_PROTECTION` | `BASIC`, `RECOVERY` |

## Examples

- [Customer Hosted](examples/customer_hosted)
- [Rubrik Hosted](examples/rubrik_hosted)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.2.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.9.1 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_null"></a> [null](#provider\_null) | >=3.2.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.9.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [null_resource.onboard](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [polaris_azure_devops_organization.org](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_devops_organization) | resource |
| [polaris_azure_devops_permissions.permissions](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/azure_devops_permissions) | data source |
| [polaris_azure_devops_script.onboard](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/azure_devops_script) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_archival_location_id"></a> [archival\_location\_id](#input\_archival\_location\_id) | Archival location ID for backups. Required when `storage_type` is `BYOS`. | `string` | `null` | no |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | Azure cloud type. Only `PUBLIC` is supported. | `string` | `"PUBLIC"` | no |
| <a name="input_delete_snapshots_on_destroy"></a> [delete\_snapshots\_on\_destroy](#input\_delete\_snapshots\_on\_destroy) | Delete the organization's snapshots when the resource is destroyed. | `bool` | `false` | no |
| <a name="input_exocompute_host_id"></a> [exocompute\_host\_id](#input\_exocompute\_host\_id) | RSC cloud account ID providing exocompute. Required when `exocompute_host_type` is `CUSTOMER_HOST`. | `string` | `null` | no |
| <a name="input_exocompute_host_type"></a> [exocompute\_host\_type](#input\_exocompute\_host\_type) | Type of exocompute host. One of `RUBRIK_HOST` (requires `exocompute_region`) or `CUSTOMER_HOST` (requires `exocompute_host_id`). | `string` | `"RUBRIK_HOST"` | no |
| <a name="input_exocompute_region"></a> [exocompute\_region](#input\_exocompute\_region) | Azure region for Rubrik-hosted exocompute (e.g. `eastus`). Required when `exocompute_host_type` is `RUBRIK_HOST`. | `string` | `null` | no |
| <a name="input_features"></a> [features](#input\_features) | RSC features with permission groups. Only AZURE\_DEVOPS\_REPOSITORY\_PROTECTION is supported. At least one permission group is required per feature. | <pre>map(object({<br/>    permission_groups = set(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_native_id"></a> [native\_id](#input\_native\_id) | Azure DevOps organization native identifier, i.e. the organization name visible in the Azure DevOps URL (e.g. `my-org` from https://dev.azure.com/my-org). | `string` | n/a | yes |
| <a name="input_onboarding_shell"></a> [onboarding\_shell](#input\_onboarding\_shell) | Shell used to run the onboarding script during the apply. One of `bash` (default) or `powershell`. The script runs before the organization is onboarded. See the module README for prerequisites. | `string` | `"bash"` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Type of backup storage. One of `RCV` (Rubrik Cloud Vault, auto-provisioned) or `BYOS` (Bring Your Own Storage, requires `archival_location_id`). | `string` | `"RCV"` | no |
| <a name="input_tenant_domain"></a> [tenant\_domain](#input\_tenant\_domain) | Azure AD tenant primary domain (e.g. `mydomain.onmicrosoft.com`). | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_organization_id"></a> [organization\_id](#output\_organization\_id) | RSC organization ID (UUID) for the onboarded Azure DevOps organization. |
<!-- END_TF_DOCS -->
