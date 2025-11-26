locals {
  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

variable "bucket_labels" {
  description = "GCP bucket labels. Each label will be added to the GCP bucket created by RSC."
  type        = map(string)
  default     = {}
}

variable "bucket_prefix" {
  description = "GCP bucket prefix. The prefix cannot be longer than 19 characters. Note that `rubrik-` will always be prepended to the prefix."
  type        = string

  validation {
    condition     = var.bucket_prefix != null && var.bucket_prefix != "" && length(var.bucket_prefix) < 20
    error_message = "Bucket prefix must be a non-empty string and cannot be longer than 19 characters."
  }
}

variable "cloud_account_id" {
  description = "RSC cloud account ID of the GCP project hosting the archival location."
  type        = string

  validation {
    condition     = var.cloud_account_id != local.uuid_null && can(regex(local.uuid_regex, var.cloud_account_id))
    error_message = "Cloud account ID must be a valid, lower case, UUID."
  }
}

variable "customer_managed_keys" {
  description = "Customer managed storage encryption. Specify the regions and their respective encryption details. For other regions, data will be encrypted using platform managed keys."
  type = set(object({
    name      = string
    region    = string
    ring_name = string
  }))
  default = null

  validation {
    condition     = var.customer_managed_keys == null || alltrue([for v in var.customer_managed_keys : (v.name != null && v.name != "" && v.ring_name != null && v.ring_name != "" && v.region != null && v.region != "")])
    error_message = "Name, ring name and region must be a non-empty strings and region must be a valid GCP storage region."
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

variable "region" {
  description = "GCP region to store the snapshots in. If not specified, the snapshots will be stored in the same region as the workload."
  type        = string
  default     = null

  validation {
    condition     = var.region == null || var.region != ""
    error_message = "Region must be a valid GCP storage region."
  }
}

variable "storage_class" {
  description = "GCP bucket storage class. Possible values are `ARCHIVE`, `COLDLINE`, `NEARLINE`, `STANDARD` and `DURABLE_REDUCED_AVAILABILITY`. Default value is `STANDARD`."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = var.storage_class != null && can(regex("ARCHIVE|COLDLINE|NEARLINE|STANDARD|DURABLE_REDUCED_AVAILABILITY", var.storage_class))
    error_message = "Storage class must be one of: ARCHIVE, COLDLINE, NEARLINE, STANDARD or DURABLE_REDUCED_AVAILABILITY."
  }
}
