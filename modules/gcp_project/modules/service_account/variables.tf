variable "account_id" {
  description = "The unique identifier for the service account within the project. Must be between 6 and 30 characters and can contain lowercase letters, numbers, and hyphens."
  type        = string
  default     = "rubrik-service-account"
}

variable "display_name" {
  description = "A human-readable name for the service account. If not specified, the module will automatically generate a display name from the `account_id`."
  type        = string
  default     = null
}

variable "rotation_trigger" {
  description = "A trigger to rotate the service account key. The trigger can be any string. When the trigger changes, the service account key will be rotated."
  type        = string
  default     = null
}
