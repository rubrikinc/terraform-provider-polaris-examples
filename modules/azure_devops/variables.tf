locals {
  features = {
    AZURE_DEVOPS_REPOSITORY_PROTECTION = [
      "BASIC",
      "RECOVERY",
    ],
  }

  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

variable "archival_location_id" {
  description = "Archival location ID for backups. Required when `storage_type` is `BYOS`."
  type        = string
  default     = null

  validation {
    condition     = var.storage_type != "BYOS" || (var.archival_location_id != null && var.archival_location_id != "")
    error_message = "Archival location ID is required when storage type is BYOS."
  }
  validation {
    condition     = var.archival_location_id == null || (var.archival_location_id != local.uuid_null && can(regex(local.uuid_regex, var.archival_location_id)))
    error_message = "The archival location ID must be a valid UUID (lower case)."
  }
}

variable "cloud" {
  description = "Azure cloud type. Only `PUBLIC` is supported."
  type        = string
  default     = "PUBLIC"

  validation {
    condition     = var.cloud == "PUBLIC"
    error_message = "Cloud type must be PUBLIC."
  }
}

variable "delete_snapshots_on_destroy" {
  description = "Delete the organization's snapshots when the resource is destroyed."
  type        = bool
  default     = false
}

variable "exocompute_host_type" {
  description = "Type of exocompute host. One of `RUBRIK_HOST` (requires `exocompute_region`) or `CUSTOMER_HOST` (requires `exocompute_host_id`)."
  type        = string
  default     = "RUBRIK_HOST"

  validation {
    condition     = contains(["RUBRIK_HOST", "CUSTOMER_HOST"], var.exocompute_host_type)
    error_message = "Exocompute host type must be one of RUBRIK_HOST or CUSTOMER_HOST."
  }
}

variable "exocompute_host_id" {
  description = "RSC cloud account ID providing exocompute. Required when `exocompute_host_type` is `CUSTOMER_HOST`."
  type        = string
  default     = null

  validation {
    condition     = var.exocompute_host_type != "CUSTOMER_HOST" || (var.exocompute_host_id != null && var.exocompute_host_id != "")
    error_message = "Exocompute host ID is required when host type is CUSTOMER_HOST."
  }
  validation {
    condition     = var.exocompute_host_id == null || (var.exocompute_host_id != local.uuid_null && can(regex(local.uuid_regex, var.exocompute_host_id)))
    error_message = "The exocompute host ID must be a valid RSC cloud account ID (UUID, lower case)."
  }
}

variable "exocompute_region" {
  description = "Azure region for Rubrik-hosted exocompute (e.g. `eastus`). Required when `exocompute_host_type` is `RUBRIK_HOST`."
  type        = string
  default     = null

  validation {
    condition     = var.exocompute_host_type != "RUBRIK_HOST" || (var.exocompute_region != null && var.exocompute_region != "")
    error_message = "Exocompute region is required when host type is RUBRIK_HOST."
  }
}

variable "features" {
  description = "RSC features with permission groups. Only AZURE_DEVOPS_REPOSITORY_PROTECTION is supported. At least one permission group is required per feature."
  type = map(object({
    permission_groups = set(string)
  }))

  validation {
    condition     = length(var.features) > 0 && length(setsubtract(keys(var.features), keys(local.features))) == 0
    error_message = format("Invalid RSC feature. Allowed features are: %s.", join(", ", keys(local.features)))
  }
  validation {
    condition = length(setsubtract(try(var.features["AZURE_DEVOPS_REPOSITORY_PROTECTION"].permission_groups, []), local.features["AZURE_DEVOPS_REPOSITORY_PROTECTION"])) == 0
    error_message = format("Invalid permission groups for AZURE_DEVOPS_REPOSITORY_PROTECTION. Allowed permission groups are: %s.", join(", ", local.features["AZURE_DEVOPS_REPOSITORY_PROTECTION"]))
  }
  validation {
    condition     = alltrue([for f in var.features : (length(f.permission_groups) > 0)])
    error_message = "At least one permission group is required per feature."
  }
}

variable "native_id" {
  description = "Azure DevOps organization native identifier, i.e. the organization name visible in the Azure DevOps URL (e.g. `my-org` from https://dev.azure.com/my-org)."
  type        = string

  validation {
    condition     = var.native_id != null && var.native_id != ""
    error_message = "Organization native ID must be a non-empty string."
  }
}

variable "onboarding_shell" {
  description = "Shell used to run the onboarding script during the apply. One of `bash` (default) or `powershell`. The script runs before the organization is onboarded. See the module README for prerequisites."
  type        = string
  default     = "bash"

  validation {
    condition     = contains(["bash", "powershell"], var.onboarding_shell)
    error_message = "onboarding_shell must be bash or powershell."
  }
}

variable "storage_type" {
  description = "Type of backup storage. One of `RCV` (Rubrik Cloud Vault, auto-provisioned) or `BYOS` (Bring Your Own Storage, requires `archival_location_id`)."
  type        = string
  default     = "RCV"

  validation {
    condition     = contains(["RCV", "BYOS"], var.storage_type)
    error_message = "Storage type must be one of RCV or BYOS."
  }
}

variable "tenant_domain" {
  description = "Azure AD tenant primary domain (e.g. `mydomain.onmicrosoft.com`)."
  type        = string

  validation {
    condition     = var.tenant_domain != null && var.tenant_domain != ""
    error_message = "Tenant domain must be a non-empty string."
  }
}
