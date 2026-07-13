resource "polaris_azure_exocompute" "exocompute" {
  cloud_account_id         = var.cloud_account_id
  pod_overlay_network_cidr = var.pod_overlay_network_cidr
  region                   = var.region
  subnet                   = var.subnet_id

  dynamic "optional_config" {
    for_each = var.optional_config != null ? [var.optional_config] : []
    content {
      allowlist_additional_ips            = optional_config.value.allowlist_additional_ips
      allowlist_rubrik_ips                = optional_config.value.allowlist_rubrik_ips
      cluster_access                      = optional_config.value.cluster_access
      cluster_tier                        = optional_config.value.cluster_tier
      disk_encryption_at_host             = optional_config.value.disk_encryption_at_host
      max_node_count                      = optional_config.value.max_node_count
      private_exocompute_dns_zone_id      = optional_config.value.private_exocompute_dns_zone_id
      resource_group_prefix               = optional_config.value.resource_group_prefix
      snapshot_private_access_dns_zone_id = optional_config.value.snapshot_private_access_dns_zone_id
      user_defined_routing                = optional_config.value.user_defined_routing
    }
  }
}
