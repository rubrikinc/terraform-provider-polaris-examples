variable "app_id" {
  description = "Application (client) ID of an existing Azure AD application. When given together with `app_secret`, the module skips creating a new application and service principal and registers the existing one with RSC. When not given, a new application is created."
  type        = string
  default     = null

  validation {
    condition     = (var.app_id == null) == (var.app_secret == null)
    error_message = "app_id and app_secret must both be set or both be null."
  }
}

variable "app_secret" {
  description = "Client secret of the existing Azure AD application. Required when `app_id` is set."
  type        = string
  default     = null
  sensitive   = true
}

variable "create_exocompute_group" {
  type        = bool
  description = "Create an Entra ID group for the RSC Exocompute feature and add the service principal as a member."
  default     = false
}

variable "display_name" {
  description = "Display name for the Azure AD application. Cannot be set together with `app_id`. When neither `app_id` nor `display_name` is specified, the application is created with the default name 'Rubrik Security Cloud - Azure Protection'."
  type        = string
  default     = null

  validation {
    condition     = var.display_name == null || var.display_name != ""
    error_message = "display_name must be a non-empty string."
  }
  validation {
    condition     = var.display_name == null || var.app_id == null
    error_message = "display_name cannot be set when app_id is given."
  }
}

variable "use_case" {
  description = "What the service principal is registered for. One of `CLOUD_NATIVE_PROTECTION` (default) or `AZURE_DEVOPS`. The credentials are stored in a separate location per use case, so a tenant can have one service principal per use case."
  type        = string
  default     = "CLOUD_NATIVE_PROTECTION"

  validation {
    condition     = contains(["CLOUD_NATIVE_PROTECTION", "AZURE_DEVOPS"], var.use_case)
    error_message = "Use case must be one of CLOUD_NATIVE_PROTECTION or AZURE_DEVOPS."
  }
}
