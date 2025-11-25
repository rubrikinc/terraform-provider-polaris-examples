# Archival Location Example

The configuration in this directory demonstrates how to create a basic RSC archival location for GCP cloud native
workloads. The configuration performs the following steps:

1. Create a GCP service account for RSC.
2. Onboard the GCP project to RSC.
3. Create an RSC archival location in the `us-central1` region.

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
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >=7.0.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp_archival_location"></a> [gcp\_archival\_location](#module\_gcp\_archival\_location) | ../.. | n/a |
| <a name="module_gcp_project"></a> [gcp\_project](#module\_gcp\_project) | ../../../gcp_project | n/a |
| <a name="module_service_account"></a> [service\_account](#module\_service\_account) | ../../../gcp_project/modules/service_account | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to apply to GCP resources created which supports labels. | `map(string)` | <pre>{<br/>  "example": "basic",<br/>  "module": "gcp_archival_location",<br/>  "repository": "terraform-provider-polaris-examples"<br/>}</pre> | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
