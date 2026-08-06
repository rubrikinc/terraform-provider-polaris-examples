# Azure Exocompute Module

This module configures RSC managed exocompute for an Azure subscription that has already been onboarded. It attaches the
exocompute configuration to an existing RSC cloud account, targeting a specific region and subnet.

## Usage

```terraform
module "azure_exocompute" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/azure_exocompute"

  cloud_account_id         = "<rsc-cloud-account-id>"
  pod_overlay_network_cidr = "10.244.0.0/16"
  region                   = "eastus2"
  subnet_id                = "<azure-subnet-id>"
}
```

## Optional Configuration

The `optional_config` variable accepts an object with the fields below. All fields are optional; any field left unset
falls back to the RSC default shown in the table. When `optional_config` itself is omitted, no optional configuration is
sent at all.

Changing any of these fields forces the exocompute configuration to be recreated.

| Field | Description | Type | Default |
| ----- | ----------- | ---- | ------- |
| `allowlist_additional_ips` | Additional IP addresses to allowlist for the API server on the Kubernetes cluster. Requires `allowlist_rubrik_ips` to be `true`. | `set(string)` | n/a |
| `allowlist_rubrik_ips` | Allowlist Rubrik IPs for the API server on the Kubernetes cluster. | `bool` | `false` |
| `cluster_access` | Azure cluster access type. One of `AKS_CLUSTER_ACCESS_TYPE_PUBLIC` or `AKS_CLUSTER_ACCESS_TYPE_PRIVATE`. | `string` | `AKS_CLUSTER_ACCESS_TYPE_PRIVATE` |
| `cluster_tier` | Azure cluster tier. One of `AKS_CLUSTER_TIER_FREE` or `AKS_CLUSTER_TIER_STANDARD`. | `string` | `AKS_CLUSTER_TIER_FREE` |
| `disk_encryption_at_host` | Enable disk encryption at host. | `bool` | `false` |
| `max_node_count` | Maximum number of nodes each cluster can use. One of `AKS_NODE_COUNT_BUCKET_SMALL` (32), `AKS_NODE_COUNT_BUCKET_MEDIUM` (64), `AKS_NODE_COUNT_BUCKET_LARGE` (128) or `AKS_NODE_COUNT_BUCKET_XLARGE` (256). The subnet must have enough IP addresses for the chosen bucket. | `string` | `AKS_NODE_COUNT_BUCKET_MEDIUM` |
| `private_exocompute_dns_zone_id` | Azure resource ID of the private DNS zone which resolves the API server URL for a private cluster. When empty, Azure creates one in the node resource group and removes it when the AKS cluster is deleted. | `string` | n/a |
| `resource_group_prefix` | Prefix of resource groups associated with the cluster, such as cluster nodes. | `string` | n/a |
| `snapshot_private_access_dns_zone_id` | Azure resource ID of the private DNS zone linked to the exocompute VNet, which resolves private endpoints linked to snapshots. When empty, a new zone is created in the exocompute resource group. | `string` | n/a |
| `user_defined_routing` | Enable user defined routing, allowing the route for the exocompute egress traffic to be configured. | `bool` | `false` |

## Examples

- [Basic Example](examples/basic)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.9.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.7.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.7.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [polaris_azure_exocompute.exocompute](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/azure_exocompute) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloud_account_id"></a> [cloud\_account\_id](#input\_cloud\_account\_id) | RSC cloud account ID of the Azure subscription. | `string` | n/a | yes |
| <a name="input_optional_config"></a> [optional\_config](#input\_optional\_config) | Optional exocompute configuration. See the module README for a description of each field and the default value. | <pre>object({<br/>    allowlist_additional_ips            = optional(set(string))<br/>    allowlist_rubrik_ips                = optional(bool)<br/>    cluster_access                      = optional(string)<br/>    cluster_tier                        = optional(string)<br/>    disk_encryption_at_host             = optional(bool)<br/>    max_node_count                      = optional(string)<br/>    private_exocompute_dns_zone_id      = optional(string)<br/>    resource_group_prefix               = optional(string)<br/>    snapshot_private_access_dns_zone_id = optional(string)<br/>    user_defined_routing                = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_pod_overlay_network_cidr"></a> [pod\_overlay\_network\_cidr](#input\_pod\_overlay\_network\_cidr) | CIDR block for the exocompute pod overlay network. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Azure exocompute region. | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Azure subnet ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_configuration_id"></a> [configuration\_id](#output\_configuration\_id) | RSC ID of the exocompute configuration. |
<!-- END_TF_DOCS -->
