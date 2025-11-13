# Basic Example

The configuration in this directory onboards a GCP project to RSC. As part of the onboarding, a GCP service account and
key are created. The service account is assigned all the permissions required by RSC.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.2.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp_project"></a> [gcp\_project](#module\_gcp\_project) | ../.. | n/a |
| <a name="module_service_account"></a> [service\_account](#module\_service\_account) | ../../modules/service_account | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
