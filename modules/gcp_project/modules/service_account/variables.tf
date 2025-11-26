variable "account_id" {
  description = "The unique identifier for the service account within the project. Must be between 6 and 30 characters and can contain lowercase letters, numbers, and hyphens."
  type        = string
  default     = "rubrik-service-account"

  validation {
    condition     = var.account_id != null && var.account_id != "" && can(regex("^[a-z0-9-]{6,30}$", var.account_id))
    error_message = "Account ID must be a valid GCP service account ID."
  }
}

variable "display_name" {
  description = "A human-readable name for the service account. If not specified, the module will automatically generate a display name from the `account_id`."
  type        = string
  default     = null

  validation {
    condition     = var.display_name == null || var.display_name != ""
    error_message = "Display name must be a non-empty string."
  }
}

variable "rotation_trigger" {
  description = "A trigger to rotate the service account key. The trigger can be any string. When the trigger changes, the service account key will be rotated."
  type        = string
  default     = null
}
