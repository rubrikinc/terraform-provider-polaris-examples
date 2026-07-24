# Azure tenant onboarding with an Exocompute group

The configuration in this directory registers a new Azure AD application and service principal with RSC using the
default application name, and creates an Entra ID group for the RSC Exocompute feature with the service principal as a
member. The group's object ID is exposed as an output.

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
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.9.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_azure_tenant"></a> [azure\_tenant](#module\_azure\_tenant) | ../.. | n/a |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_exocompute_group_id"></a> [exocompute\_group\_id](#output\_exocompute\_group\_id) | Object ID of the Entra ID Exocompute group. |
<!-- END_TF_DOCS -->
