# GCP Exocompute Module

This module creates an RSC Exocompute configuration for GCP workloads using customer managed networking. The GCP project
must be onboarded with the `EXOCOMPUTE` feature without the `AUTOMATED_NETWORKING_SETUP` permission group. Note, if the
GCP project was onboarded with the `AUTOMATED_NETWORKING_SETUP` permission group, RSC will automatically create and
manage the networking resources for Exocompute.

## Usage

```terraform
module "gcp_exocompute" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/gcp_exocompute"

  cloud_account_id =  module.gcp_project.cloud_account_id

  regional_configs = [
    {
      region      = "us-west1"
      subnet_name = "my-subnet"
      vpc_name    = "my-vpc"
    },
  ]
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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.4.0 |

## Resources

| Name | Type |
|------|------|
| [polaris_gcp_exocompute.exocompute](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/gcp_exocompute) | resource |
| [polaris_gcp_project.project](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/gcp_project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_account_id"></a> [cloud\_account\_id](#input\_cloud\_account\_id) | RSC cloud account ID of the GCP project hosting the archival location. | `string` | n/a | yes |
| <a name="input_regional_configs"></a> [regional\_configs](#input\_regional\_configs) | Regional exocompute configurations. | <pre>set(object({<br/>    region      = string<br/>    subnet_name = string<br/>    vpc_name    = string<br/>  }))</pre> | n/a | yes |
| <a name="input_trigger_health_check"></a> [trigger\_health\_check](#input\_trigger\_health\_check) | Trigger a health check after creating the exocompute configuration. | `bool` | `null` | no |
<!-- END_TF_DOCS -->
