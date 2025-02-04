variable "cluster_name" {
  description = "Azure AKS cluster name. Must be given as <resource-group>/<cluster-name>."
  type        = string
}

variable "cluster_resource_group" {
  description = "Azure AKS cluster resource group."
  type        = string
}

variable "features" {
  type = map(object({
    permission_groups = set(string)
  }))
  description = "RSC features with permission groups to enable."
}

variable "managed_identity_name" {
  default     = "terraform-azure-exocompute-byok-example"
  description = "Azure user assigned managed identity name."
  type        = string
}

variable "region" {
  default     = "eastus2"
  description = "Azure region."
  type        = string
}

variable "registry_url" {
  description = "Private container registry URL."
  type        = string
}

variable "resource_group_name" {
  default     = "terraform-azure-exocompute-byok-example"
  description = "Azure resource group name."
  type        = string
}
