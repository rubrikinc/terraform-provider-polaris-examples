# GCP Project with Key Rotation Example

The configuration in this directory onboards a GCP project to RSC using a service account and key. The key is configured
to be rotated every 90 days. The service account is assigned all the permissions required by RSC.

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
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp_project"></a> [gcp\_project](#module\_gcp\_project) | ../.. | n/a |
| <a name="module_service_account"></a> [service\_account](#module\_service\_account) | ../../modules/service_account | n/a |

## Resources

| Name | Type |
|------|------|
| [time_rotating.key_rotation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project id. | `string` | n/a | yes |
<!-- END_TF_DOCS -->
