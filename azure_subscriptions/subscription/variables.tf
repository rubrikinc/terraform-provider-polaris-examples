variable "features" {
  type        = set(string)
  description = "List of features to enable."
}

variable "principal_id" {
  type        = string
  description = "Azure AD principal ID."
}

variable "regions" {
  type        = set(string)
  description = "Azure regions to the RSC features for."
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name."
}

variable "resource_group_region" {
  type        = string
  description = "Azure resource group region."
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID."
}

variable "tenant_domain" {
  type        = string
  description = "Azure AD tenant domain."
}
