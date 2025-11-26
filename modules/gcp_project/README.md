# GCP Project Module

This module manages the onboarding of a GCP project to RSC. The module configures the necessary GCP IAM roles and
permissions for the specified set of RSC features and permission groups. A GCP service account must be provided, it will
be assigned all the permissions required by the selected RSC features. The service account key will be provided to RSC
for authentication with GCP when it performs operations on the GCP project.

> [!NOTE]
> The module automatically enables the required GCP APIs for the selected features. The enabled APIs remain active even
> after destroying the module to prevent disruption to other workloads.

> [!NOTE]
> The module validates that the specified features and permission groups are valid. If the validation fails, Terraform
> will produce an error during the plan/apply phase.

## Usage

```terraform
module "gcp_project" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_project"
  project_id = var.project_id
  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC",
        "ENCRYPTION",
      ]
    },
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
        "EXPORT_AND_RESTORE",
        "FILE_LEVEL_RECOVERY",
      ]
    },
    GCP_SHARED_VPC_HOST = {
      permission_groups = [
        "BASIC",
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
      ]
    },
  }
}
```

## Examples

- [Basic Example](examples/basic)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.11.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=7.0.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.3.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=7.0.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.3.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.1 |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_custom_role.with_conditions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_custom_role.without_conditions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.with_conditions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.without_conditions](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [polaris_gcp_project.project](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/gcp_project) | resource |
| [time_sleep.wait_for_rsc](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_service_account.service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/service_account) | data source |
| [polaris_gcp_permissions.permissions](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/gcp_permissions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_features"></a> [features](#input\_features) | RSC features with permission groups. Possible features are: CLOUD\_NATIVE\_ARCHIVAL, CLOUD\_NATIVE\_PROTECTION, EXOCOMPUTE and GCP\_SHARED\_VPC\_HOST. | <pre>map(object({<br/>    permission_groups = set(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | GCP organization name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
| <a name="input_role_id_prefix"></a> [role\_id\_prefix](#input\_role\_id\_prefix) | Role ID prefix for the GCP roles created. | `string` | `"rubrik_role"` | no |
| <a name="input_role_title_prefix"></a> [role\_title\_prefix](#input\_role\_title\_prefix) | Role title prefix for the GCP roles created. Defaults to `role_id_prefix` with underscores replaced by spaces and the first letter of each word capitalized. | `string` | `null` | no |
| <a name="input_service_account_id"></a> [service\_account\_id](#input\_service\_account\_id) | GCP service account ID. The ID can be the name, the fully qualified path or the email address of the service account. | `string` | n/a | yes |
| <a name="input_service_account_key"></a> [service\_account\_key](#input\_service\_account\_key) | Base64 encoded private key for the GCP service account. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_account_id"></a> [cloud\_account\_id](#output\_cloud\_account\_id) | RSC cloud account ID for the GCP project. |
<!-- END_TF_DOCS -->
