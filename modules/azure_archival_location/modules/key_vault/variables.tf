variable "grant_creator_key_permissions" {
  description = "Whether to grant the current Azure credentials the `Key Vault Crypto Officer` role on the key vault so that the key can be created. Requires permission to create role assignments. Set to false if the role has been granted out of band."
  type        = bool
  default     = true
}

variable "key_name" {
  description = "The name of the key to create in the key vault."
  type        = string

  validation {
    condition     = var.key_name != null && var.key_name != ""
    error_message = "Key name must be a non-empty string."
  }
}

variable "key_opts" {
  description = "The permitted operations for the key. Archival encryption requires at least `wrapKey` and `unwrapKey`."
  type        = list(string)
  default     = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
}

variable "key_size" {
  description = "The size of the key in bits. Only applies to RSA keys. Default value is 2048."
  type        = number
  default     = 2048
}

variable "key_type" {
  description = "The type of key to create. Possible values are `RSA`, `RSA-HSM`, `EC` and `EC-HSM`. Default value is `RSA`."
  type        = string
  default     = "RSA"

  validation {
    condition     = can(regex("^(RSA|RSA-HSM|EC|EC-HSM)$", var.key_type))
    error_message = "Key type must be one of: RSA, RSA-HSM, EC or EC-HSM."
  }
}

variable "key_vault_name" {
  description = "The name of the key vault to create. Key vault names must be globally unique."
  type        = string

  validation {
    condition     = var.key_vault_name != null && var.key_vault_name != ""
    error_message = "Key vault name must be a non-empty string."
  }
}

variable "location" {
  description = "The Azure region in which to create the key vault."
  type        = string

  validation {
    condition     = var.location != null && var.location != ""
    error_message = "Location must be a non-empty string."
  }
}

variable "purge_protection_enabled" {
  description = "Whether purge protection is enabled for the key vault. Once enabled it cannot be disabled."
  type        = bool
  default     = false
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the key vault. The resource group must already exist."
  type        = string

  validation {
    condition     = var.resource_group_name != null && var.resource_group_name != ""
    error_message = "Resource group name must be a non-empty string."
  }
}

variable "role_propagation_delay" {
  description = "How long to wait for the `Key Vault Crypto Officer` role assignment to propagate before creating the key. Only applies when grant_creator_key_permissions is true."
  type        = string
  default     = "60s"
}

variable "sku_name" {
  description = "The key vault SKU. Possible values are `standard` and `premium`. Default value is `standard`."
  type        = string
  default     = "standard"

  validation {
    condition     = can(regex("^(standard|premium)$", var.sku_name))
    error_message = "SKU name must be one of: standard or premium."
  }
}

variable "tags" {
  description = "Tags to apply to the key vault and key."
  type        = map(string)
  default     = {}
}

