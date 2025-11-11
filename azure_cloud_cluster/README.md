# Azure Cloud Cluster

The configuration in this directory onboards an Azure subscription to RSC and creates an Azure cloud cluster using RSC.

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
|------|---------|
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_azure_subscription"></a> [azure\_subscription](#module\_azure\_subscription) | ../azure | n/a |

## Resources

| Name | Type |
|------|------|
| [polaris_azure_cloud_cluster.cces](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_cloud_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Admin email for the cluster | `string` | `"admin@example.com"` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the cluster | `string` | `"RubrikGoForward!"` | no |
| <a name="input_cdm_version"></a> [cdm\_version](#input\_cdm\_version) | CDM version for the cluster | `string` | `"9.2.3-p8-29766"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Azure cloud cluster | `string` | `"my-cces-cluster"` | no |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Azure storage container name | `string` | `"mycontainer"` | no |
| <a name="input_dns_name_servers"></a> [dns\_name\_servers](#input\_dns\_name\_servers) | List of DNS name servers | `list(string)` | <pre>[<br/>  "8.8.8.8",<br/>  "8.8.4.4"<br/>]</pre> | no |
| <a name="input_enable_immutability"></a> [enable\_immutability](#input\_enable\_immutability) | Enable immutability for the cluster | `bool` | `false` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Azure instance type, Allowed values are `STANDARD_DS5_V2`, `STANDARD_D16S_V5`, `STANDARD_D8S_V5`, `STANDARD_D32S_V5`, `STANDARD_E16S_V5`, `STANDARD_D8AS_V5`, `STANDARD_D16AS_V5`, `STANDARD_D32AS_V5` and `STANDARD_E16AS_V5` | `string` | `"STANDARD_D8S_V5"` | no |
| <a name="input_keep_cluster_on_failure"></a> [keep\_cluster\_on\_failure](#input\_keep\_cluster\_on\_failure) | Keep cluster on failure | `bool` | `true` | no |
| <a name="input_network_resource_group"></a> [network\_resource\_group](#input\_network\_resource\_group) | Azure network resource group name | `string` | `"my-network-resource-group"` | no |
| <a name="input_network_security_group"></a> [network\_security\_group](#input\_network\_security\_group) | Azure network security group name | `string` | `"my-nsg"` | no |
| <a name="input_network_security_resource_group"></a> [network\_security\_resource\_group](#input\_network\_security\_resource\_group) | Azure network security resource group name | `string` | `"my-nsg-resource-group"` | no |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | List of NTP servers | `list(string)` | <pre>[<br/>  "pool.ntp.org"<br/>]</pre> | no |
| <a name="input_num_nodes"></a> [num\_nodes](#input\_num\_nodes) | Number of nodes in the cluster | `number` | `3` | no |
| <a name="input_region"></a> [region](#input\_region) | Azure region | `string` | `"centralus"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Azure resource group name | `string` | `"my-resource-group"` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Azure storage account name | `string` | `"mystorageaccount"` | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Azure subnet name | `string` | `"my-subnet"` | no |
| <a name="input_user_assigned_managed_identity_name"></a> [user\_assigned\_managed\_identity\_name](#input\_user\_assigned\_managed\_identity\_name) | User assigned managed identity name | `string` | `"my-managed-identity"` | no |
| <a name="input_vm_type"></a> [vm\_type](#input\_vm\_type) | VM type for the cluster | `string` | `"EXTRA_DENSE"` | no |
| <a name="input_vnet"></a> [vnet](#input\_vnet) | Azure virtual network name | `string` | `"my-vnet"` | no |
| <a name="input_vnet_resource_group"></a> [vnet\_resource\_group](#input\_vnet\_resource\_group) | Azure virtual network resource group name | `string` | `"my-vnet-resource-group"` | no |
<!-- END_TF_DOCS -->
