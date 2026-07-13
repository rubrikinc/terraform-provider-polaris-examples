locals {
  features_with_resource_group = [
    "CLOUD_NATIVE_ARCHIVAL",
    "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION",
    "CLOUD_NATIVE_PROTECTION",
    "EXOCOMPUTE",
    "SERVERS_AND_APPS",
    "AZURE_SQL_DB_PROTECTION",
  ]

  features_with_user_assigned_identity = [
    "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION",
    "AZURE_SQL_DB_PROTECTION",
  ]

  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

variable "default_resource_group" {
  description = "Default Azure resource group. The default is used when a feature specific one isn't specified and it is required by RSC."
  type = object({
    name = string
    tags = optional(map(string))
  })
  default = null

  validation {
    condition     = var.default_resource_group == null || var.default_resource_group.name != ""
    error_message = "The default resource group name must not be empty when specified."
  }
}

variable "default_user_assigned_identity" {
  description = "Default Azure user assigned identity. The default is used when a feature specific one isn't specified and it is required by RSC."
  type = object({
    name                = string
    resource_group_name = string
    tags                = optional(map(string))
  })
  default = null

  validation {
    condition     = var.default_user_assigned_identity == null || (var.default_user_assigned_identity.name != "" && var.default_user_assigned_identity.resource_group_name != "")
    error_message = "The default user assigned identity name and resource group name must not be empty when specified."
  }
}

variable "exocompute_host_id" {
  description = "RSC cloud account ID (UUID) of the Azure subscription hosting exocompute. When set, this subscription is registered as a shared exocompute application account, using the exocompute resources deployed by the host subscription."
  type        = string
  default     = null

  validation {
    condition     = var.exocompute_host_id == null || (var.exocompute_host_id != local.uuid_null && can(regex(local.uuid_regex, var.exocompute_host_id)))
    error_message = "The exocompute host ID must be the RSC cloud account ID (UUID, lower case) of the Azure subscription hosting exocompute."
  }
}

variable "features" {
  description = "RSC features with permission groups, resource groups and user assigned identities."
  type = map(object({
    permission_groups = set(string)
    resource_group = optional(object({
      name = string
      tags = optional(map(string))
    }))
    user_assigned_identity = optional(object({
      name                = string
      resource_group_name = string
      tags                = optional(map(string))
    }))
  }))

  validation {
    condition     = length(var.features) > 0
    error_message = "At least one feature must be specified."
  }
  validation {
    condition = alltrue([
      for v in values(var.features) : (length(v.permission_groups) > 0)
    ])
    error_message = "Each feature must specify at least one permission group."
  }
  validation {
    condition = alltrue([
      for k, v in var.features : (v.resource_group != null || var.default_resource_group != null) if contains(local.features_with_resource_group, k)
    ])
    error_message = format("Features requiring a resource group (%s) must have a feature specific or default resource group.", join(", ", local.features_with_resource_group))
  }
  validation {
    condition = alltrue([
      for v in values(var.features) : (v.resource_group == null || v.resource_group.name != "")
    ])
    error_message = "The resource group name of a feature must not be empty when specified."
  }
  validation {
    condition = alltrue([
      for k, v in var.features : (v.user_assigned_identity != null || var.default_user_assigned_identity != null) if contains(local.features_with_user_assigned_identity, k)
    ])
    error_message = format("Features requiring a user assigned identity (%s) must have a feature specific or default user assigned identity.", join(", ", local.features_with_user_assigned_identity))
  }
  validation {
    condition = alltrue([
      for v in values(var.features) : (v.user_assigned_identity == null || (v.user_assigned_identity.name != "" && v.user_assigned_identity.resource_group_name != ""))
    ])
    error_message = "The user assigned identity name and resource group name of a feature must not be empty when specified."
  }
}

variable "regions" {
  type        = set(string)
  description = "Azure regions to protect with RSC."

  validation {
    condition     = length(var.regions) > 0
    error_message = "At least one region must be specified."
  }
}

variable "role_prefix" {
  description = "Prefix for Azure role names created by RSC. Defaults to *Rubrik Security Cloud*."
  type        = string
  default     = "Rubrik Security Cloud"

  validation {
    condition     = var.role_prefix != ""
    error_message = "Role prefix must not be empty."
  }
}

variable "principal_id" {
  type        = string
  description = "Object ID of the Azure AD service principal used by RSC. This is the same ID used as principal_id in Azure RBAC role assignments."

  validation {
    condition     = var.principal_id != ""
    error_message = "The service principal object ID must not be empty."
  }
}

variable "tenant_domain" {
  type        = string
  description = "Azure tenant domain."

  validation {
    condition     = var.tenant_domain != ""
    error_message = "The tenant domain must not be empty."
  }
}
