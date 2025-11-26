locals {
  features = [
    "CLOUD_NATIVE_ARCHIVAL",
    "CLOUD_NATIVE_PROTECTION",
    "EXOCOMPUTE",
    "GCP_SHARED_VPC_HOST",
  ]

  cloud_native_archival = [
    "BASIC",
    "ENCRYPTION",
  ]

  cloud_native_protection = [
    "BASIC",
    "EXPORT_AND_RESTORE",
    "FILE_LEVEL_RECOVERY",
  ]

  exocompute = [
    "BASIC",
  ]

  gcp_shared_vpc_host = [
    "BASIC",
  ]
}

variable "features" {
  description = "RSC features with permission groups. Possible features are: CLOUD_NATIVE_ARCHIVAL, CLOUD_NATIVE_PROTECTION, EXOCOMPUTE and GCP_SHARED_VPC_HOST."
  type = map(object({
    permission_groups = set(string)
  }))

  validation {
    condition     = var.features != null && length(var.features) > 0 && length(setsubtract(keys(var.features), local.features)) == 0
    error_message = format("Invalid RSC feature. Allowed features are: %v.", join(", ", local.features))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_ARCHIVAL"].permission_groups, []), local.cloud_native_archival)) == 0
    error_message = format("Invalid permission groups for CLOUD_NATIVE_ARCHIVAL feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_archival))
  }
  validation {
    condition     = length(setsubtract(try(var.features["CLOUD_NATIVE_PROTECTION"].permission_groups, []), local.cloud_native_protection)) == 0
    error_message = format("Invalid permission groups for CLOUD_NATIVE_PROTECTION feature. Allowed permission groups are: %v.", join(", ", local.cloud_native_protection))
  }
  validation {
    condition     = length(setsubtract(try(var.features["EXOCOMPUTE"].permission_groups, []), local.exocompute)) == 0
    error_message = format("Invalid permission groups for EXOCOMPUTE feature. Allowed permission groups are: %v.", join(", ", local.exocompute))
  }
  validation {
    condition     = length(setsubtract(try(var.features["GCP_SHARED_VPC_HOST"].permission_groups, []), local.gcp_shared_vpc_host)) == 0
    error_message = format("Invalid permission groups for GCP_SHARED_VPC_HOST feature. Allowed permission groups are: %v.", join(", ", local.gcp_shared_vpc_host))
  }
}

variable "organization_name" {
  description = "GCP organization name."
  type        = string
  default     = null
}

variable "project_id" {
  description = "GCP project ID."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be a valid GCP project ID."
  }
}

variable "role_id_prefix" {
  description = "Role ID prefix for the GCP roles created."
  type        = string
  default     = "rubrik_role"

  validation {
    condition     = var.role_id_prefix != null && var.role_id_prefix != ""
    error_message = "Role ID prefix must be a non-empty string."
  }
}

variable "role_title_prefix" {
  description = "Role title prefix for the GCP roles created. Defaults to `role_id_prefix` with underscores replaced by spaces and the first letter of each word capitalized."
  type        = string
  default     = null

  validation {
    condition     = var.role_title_prefix == null || var.role_title_prefix != ""
    error_message = "Role title prefix must be a non-empty string."
  }
}

variable "service_account_id" {
  description = "GCP service account ID. The ID can be the name, the fully qualified path or the email address of the service account."
  type        = string

  validation {
    condition     = var.service_account_id != null && var.service_account_id != ""
    error_message = "Service account ID must be a non-empty string."
  }
}

variable "service_account_key" {
  description = "Base64 encoded private key for the GCP service account."
  type        = string

  validation {
    condition     = var.service_account_key != null && var.service_account_key != ""
    error_message = "Service account key must be a non-empty string."
  }
}
