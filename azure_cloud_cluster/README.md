# Azure Cloud Cluster

The configuration in this directory onboards an Azure subscription to RSC and creates an Azure cloud cluster using RSC.

The cloud account ID can be obtained by first onboarding the subscription to RSC using the `azure` module in this
repository which provides the output ID.

## Usage

```terraform
resource "polaris_azure_cloud_cluster" "cces" {
  cloud_account_id = "00000000-0000-0000-0000-000000000000"

  cluster_config {
    cluster_name            = "my-cces-cluster"
    admin_email             = "admin@example.com"
    admin_password          = "RubrikGoForward!"
    dns_name_servers        = ["8.8.8.8", "8.8.4.4"]
    ntp_servers             = ["pool.ntp.org"]
    num_nodes               = 3
    keep_cluster_on_failure = false
  }

  # VM config items should already exist in Azure
  vm_config {
    cdm_version                         = "9.2.3-p8-29766"
    instance_type                       = "STANDARD_D8S_V5"
    region                              = "centralus"
    resource_group_name                 = "my-resource-group"
    network_resource_group              = "my-network-resource-group"
    vnet_resource_group                 = "my-vnet-resource-group"
    subnet                              = "my-subnet"
    vnet                                = "my-vnet"
    network_security_group              = "my-nsg"
    network_security_resource_group     = "my-nsg-resource-group"
    vm_type                             = "EXTRA_DENSE"
    user_assigned_managed_identity_name = "terraform-mi"
    storage_account_name                = "my-storage-account"
    container_name                      = "rbrk"
    enable_immutability                 = false
  }
}
```

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
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Admin email for the cluster | `string` | n/a | yes |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the cluster | `string` | n/a | yes |
| <a name="input_cdm_version"></a> [cdm\_version](#input\_cdm\_version) | CDM version for the cluster, this can be found in RSC from the upgrades portal, and will be formatted like 9.2.3-p8-29766 | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the Azure cloud cluster | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Azure storage container name | `string` | n/a | yes |
| <a name="input_dns_name_servers"></a> [dns\_name\_servers](#input\_dns\_name\_servers) | List of DNS name servers for the cluster | `list(string)` | n/a | yes |
| <a name="input_enable_immutability"></a> [enable\_immutability](#input\_enable\_immutability) | Enable immutability for the cluster | `bool` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Azure instance type, Allowed values are `STANDARD_DS5_V2`, `STANDARD_D16S_V5`, `STANDARD_D8S_V5`, `STANDARD_D32S_V5`, `STANDARD_E16S_V5`, `STANDARD_D8AS_V5`, `STANDARD_D16AS_V5`, `STANDARD_D32AS_V5` and `STANDARD_E16AS_V5` | `string` | n/a | yes |
| <a name="input_keep_cluster_on_failure"></a> [keep\_cluster\_on\_failure](#input\_keep\_cluster\_on\_failure) | Keep cluster on failure | `bool` | n/a | yes |
| <a name="input_network_resource_group"></a> [network\_resource\_group](#input\_network\_resource\_group) | Azure network resource group name for the network security group. | `string` | n/a | yes |
| <a name="input_network_security_group"></a> [network\_security\_group](#input\_network\_security\_group) | Azure network security group name | `string` | n/a | yes |
| <a name="input_network_security_resource_group"></a> [network\_security\_resource\_group](#input\_network\_security\_resource\_group) | Azure network security resource group name | `string` | n/a | yes |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | List of NTP servers for the cluster | `list(string)` | n/a | yes |
| <a name="input_num_nodes"></a> [num\_nodes](#input\_num\_nodes) | Number of nodes in the cluster, this can be 1, 3, 4, 5 and so on. | `number` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure region using the programmatic name as per https://learn.microsoft.com/en-us/azure/reliability/regions-list | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Azure resource group name for the cluster resources. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | Azure storage account name | `string` | n/a | yes |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | Azure subnet name | `string` | n/a | yes |
| <a name="input_user_assigned_managed_identity_name"></a> [user\_assigned\_managed\_identity\_name](#input\_user\_assigned\_managed\_identity\_name) | User assigned managed identity name | `string` | n/a | yes |
| <a name="input_vm_type"></a> [vm\_type](#input\_vm\_type) | VM type for the cluster, alllowed values are `STANDARD`, `EXTRA_DENSE` and `DENSE`. `EXTRA_DENSE` is the recommended value. | `string` | `"EXTRA_DENSE"` | no |
| <a name="input_vnet"></a> [vnet](#input\_vnet) | Azure virtual network name | `string` | n/a | yes |
| <a name="input_vnet_resource_group"></a> [vnet\_resource\_group](#input\_vnet\_resource\_group) | Azure virtual network resource group name | `string` | n/a | yes |
<!-- END_TF_DOCS -->
