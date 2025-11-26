variable "key_name" {
  description = "The name of the KMS crypto key. If a crypto key with this name already exists in the key ring, it will be used; otherwise, a new one will be created."
  type        = string

  validation {
    condition     = var.key_name != null && var.key_name != ""
    error_message = "Key name must be a non-empty string."
  }
}

variable "key_ring_name" {
  description = "The name of the KMS key ring that will contain the crypto key. If a key ring with this name already exists in the region, it will be used; otherwise, a new one will be created."
  type        = string

  validation {
    condition     = var.key_ring_name != null && var.key_ring_name != ""
    error_message = "Key ring name must be a non-empty string."
  }
}

variable "key_rotation_period" {
  description = "The rotation period for the crypto key in seconds. The key will be automatically rotated at this interval. Only applies when creating a new crypto key. Default is 2592000s (30 days)."
  type        = string
  default     = "2592000s"

  validation {
    condition     = var.key_rotation_period != null && can(regex("^[0-9]+s$", var.key_rotation_period))
    error_message = "Rotation period must be a valid duration in seconds."
  }
}

variable "region" {
  description = "The GCP region where the key ring and crypto key will be created or looked up."
  type        = string

  validation {
    condition     = var.region != null && var.region != ""
    error_message = "Region must be a valid GCP region."
  }
}

variable "labels" {
  description = "Labels to apply to the crypto key. Only applies when creating a new crypto key."
  type        = map(string)
  default     = {}
}
