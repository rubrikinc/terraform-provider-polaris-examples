variable "name" {
  description = "Name of the custom role."
  type        = string

  validation {
    condition     = length(var.name) > 0
    error_message = "Name must not be empty."
  }
}

variable "description" {
  description = "Description of the custom role."
  type        = string
  default     = null
}

variable "permissions" {
  description = "List of permissions for the custom role. Each permission specifies an operation and a list of hierarchies defining the scope."
  type = list(object({
    operation = string
    hierarchy = list(object({
      snappable_type = string
      object_ids     = list(string)
    }))
  }))

  validation {
    condition     = length(var.permissions) > 0
    error_message = "At least one permission must be specified."
  }
}

variable "user_ids" {
  description = "Set of user IDs to assign the custom role to."
  type        = set(string)
  default     = []
}

variable "sso_group_ids" {
  description = "Set of SSO group IDs to assign the custom role to."
  type        = set(string)
  default     = []
}
