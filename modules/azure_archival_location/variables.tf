locals {
  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

variable "cloud_account_id" {
  description = "RSC cloud account ID of the Azure subscription hosting the archival location."
  type        = string

  validation {
    condition     = var.cloud_account_id != local.uuid_null && can(regex(local.uuid_regex, var.cloud_account_id))
    error_message = "Cloud account ID must be a valid, lower case, UUID."
  }
}

variable "customer_managed_keys" {
  description = "Customer managed storage encryption. Specify the regions and their respective encryption details. For other regions, data will be encrypted using platform managed keys. Only key vaults using Azure RBAC authorization are supported."
  type = set(object({
    name                = string
    region              = string
    vault_name          = string
    resource_group_name = string
  }))
  default = null

  validation {
    condition     = var.customer_managed_keys == null || alltrue([for v in var.customer_managed_keys : (v.name != null && v.name != "" && v.region != null && v.region != "" && v.vault_name != null && v.vault_name != "" && v.resource_group_name != null && v.resource_group_name != "")])
    error_message = "Name, region, vault name and resource group name must be non-empty strings."
  }
}

variable "name" {
  description = "Name of the cloud archival location."
  type        = string

  validation {
    condition     = var.name != null && var.name != ""
    error_message = "Name must be a non-empty string."
  }
}

variable "network_access_type" {
  description = "Azure storage account network access type. Possible values are `PRIVATE`, `PUBLIC` and `SELECTED_NETWORKS`. If not specified, RSC decides the default."
  type        = string
  default     = null

  validation {
    condition     = var.network_access_type == null || can(regex("^(PRIVATE|PUBLIC|SELECTED_NETWORKS)$", var.network_access_type))
    error_message = "Network access type must be one of: PRIVATE, PUBLIC or SELECTED_NETWORKS."
  }
}

variable "redundancy" {
  description = "Azure storage redundancy. Possible values are `GRS`, `GZRS`, `LRS`, `RA_GRS`, `RA_GZRS` and `ZRS`. Default value is `LRS`."
  type        = string
  default     = "LRS"

  validation {
    condition     = var.redundancy != null && can(regex("^(GRS|GZRS|LRS|RA_GRS|RA_GZRS|ZRS)$", var.redundancy))
    error_message = "Redundancy must be one of: GRS, GZRS, LRS, RA_GRS, RA_GZRS or ZRS."
  }
}

variable "storage_account_name_prefix" {
  description = "Azure storage account name prefix. When `storage_account_region` is not specified (`SOURCE_REGION`), the prefix cannot be longer than 16 characters. When `storage_account_region` is specified (`SPECIFIC_REGION`), the prefix cannot be longer than 24 characters. The prefix can only consist of lower case letters and numbers."
  type        = string

  validation {
    condition     = var.storage_account_name_prefix != null && can(regex("^[a-z0-9]+$", var.storage_account_name_prefix))
    error_message = "Storage account name prefix must be a non-empty string consisting only of lower case letters and numbers."
  }
  validation {
    condition     = length(var.storage_account_name_prefix) <= (var.storage_account_region == null ? 16 : 24)
    error_message = "Storage account name prefix cannot be longer than 16 characters for SOURCE_REGION (no storage_account_region specified) or 24 characters for SPECIFIC_REGION."
  }
}

variable "storage_account_region" {
  description = "Azure region to store the snapshots in. If not specified, the snapshots will be stored in the same region as the workload."
  type        = string
  default     = null

  validation {
    condition     = var.storage_account_region == null || var.storage_account_region != ""
    error_message = "Storage account region must be a non-empty string when specified."
  }
}

variable "storage_account_tags" {
  description = "Azure storage account tags. Each tag will be added to the storage account created by RSC."
  type        = map(string)
  default     = {}
}

variable "storage_tier" {
  description = "Azure storage tier. Possible values are `COOL` and `HOT`. Default value is `COOL`."
  type        = string
  default     = "COOL"

  validation {
    condition     = var.storage_tier != null && can(regex("^(COOL|HOT)$", var.storage_tier))
    error_message = "Storage tier must be one of: COOL or HOT."
  }
}
