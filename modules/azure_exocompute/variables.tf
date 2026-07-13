variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the Azure subscription."

  validation {
    condition     = var.cloud_account_id != ""
    error_message = "The cloud account ID must not be empty."
  }
}

variable "pod_overlay_network_cidr" {
  type        = string
  description = "CIDR block for the exocompute pod overlay network."

  validation {
    condition     = can(cidrhost(var.pod_overlay_network_cidr, 0))
    error_message = "The pod overlay network CIDR must be a valid CIDR block."
  }
}

variable "region" {
  type        = string
  description = "Azure exocompute region."

  validation {
    condition     = var.region != ""
    error_message = "The region must not be empty."
  }
}

variable "subnet_id" {
  type        = string
  description = "Azure subnet ID."

  validation {
    condition     = var.subnet_id != ""
    error_message = "The subnet ID must not be empty."
  }
}

variable "optional_config" {
  description = "Optional exocompute configuration. See the module README for a description of each field and the default value."
  type = object({
    allowlist_additional_ips            = optional(set(string))
    allowlist_rubrik_ips                = optional(bool)
    cluster_access                      = optional(string)
    cluster_tier                        = optional(string)
    disk_encryption_at_host             = optional(bool)
    max_node_count                      = optional(string)
    private_exocompute_dns_zone_id      = optional(string)
    resource_group_prefix               = optional(string)
    snapshot_private_access_dns_zone_id = optional(string)
    user_defined_routing                = optional(bool)
  })
  default = null

  validation {
    condition     = var.optional_config == null || var.optional_config.allowlist_additional_ips == null || var.optional_config.allowlist_rubrik_ips == true
    error_message = "allowlist_additional_ips requires allowlist_rubrik_ips to be true."
  }
  validation {
    condition     = try(contains(["AKS_CLUSTER_ACCESS_TYPE_PUBLIC", "AKS_CLUSTER_ACCESS_TYPE_PRIVATE"], var.optional_config.cluster_access), true)
    error_message = "cluster_access must be one of AKS_CLUSTER_ACCESS_TYPE_PUBLIC or AKS_CLUSTER_ACCESS_TYPE_PRIVATE."
  }
  validation {
    condition     = try(contains(["AKS_CLUSTER_TIER_FREE", "AKS_CLUSTER_TIER_STANDARD"], var.optional_config.cluster_tier), true)
    error_message = "cluster_tier must be one of AKS_CLUSTER_TIER_FREE or AKS_CLUSTER_TIER_STANDARD."
  }
  validation {
    condition     = try(contains(["AKS_NODE_COUNT_BUCKET_SMALL", "AKS_NODE_COUNT_BUCKET_MEDIUM", "AKS_NODE_COUNT_BUCKET_LARGE", "AKS_NODE_COUNT_BUCKET_XLARGE"], var.optional_config.max_node_count), true)
    error_message = "max_node_count must be one of AKS_NODE_COUNT_BUCKET_SMALL, AKS_NODE_COUNT_BUCKET_MEDIUM, AKS_NODE_COUNT_BUCKET_LARGE or AKS_NODE_COUNT_BUCKET_XLARGE."
  }
}
