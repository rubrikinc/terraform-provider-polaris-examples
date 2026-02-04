locals {
  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

variable "cloud_account_id" {
  description = "RSC cloud account ID of the GCP project hosting the archival location."
  type        = string

  validation {
    condition     = var.cloud_account_id != local.uuid_null && can(regex(local.uuid_regex, var.cloud_account_id))
    error_message = "Cloud account ID must be a valid, lower case, UUID."
  }
}

variable "regional_configs" {
  description = "Regional exocompute configurations."
  type = set(object({
    region      = string
    subnet_name = string
    vpc_name    = string
  }))
}

variable "trigger_health_check" {
  description = "Trigger a health check after creating the exocompute configuration."
  type        = bool
  default     = null
}
