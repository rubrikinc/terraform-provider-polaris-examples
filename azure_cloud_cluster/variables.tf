variable "cluster_name" {
  description = "The name of the Azure cloud cluster"
  type        = string
}

variable "admin_email" {
  description = "Admin email for the cluster"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the cluster"
  type        = string
  sensitive   = true
}

variable "dns_name_servers" {
  description = "List of DNS name servers for the cluster"
  type        = list(string)
}

variable "ntp_servers" {
  description = "List of NTP servers for the cluster"
  type        = list(string)
}

variable "num_nodes" {
  description = "Number of nodes in the cluster, this can be 1, 3, 4, 5 and so on."
  type        = number
}

variable "keep_cluster_on_failure" {
  description = "Keep cluster on failure"
  type        = bool
}

variable "cdm_version" {
  description = "CDM version for the cluster, this can be found in RSC from the upgrades portal, and will be formatted like 9.2.3-p8-29766"
  type        = string
}

variable "instance_type" {
  description = "Azure instance type, Allowed values are `STANDARD_DS5_V2`, `STANDARD_D16S_V5`, `STANDARD_D8S_V5`, `STANDARD_D32S_V5`, `STANDARD_E16S_V5`, `STANDARD_D8AS_V5`, `STANDARD_D16AS_V5`, `STANDARD_D32AS_V5` and `STANDARD_E16AS_V5`"
  type        = string
}

variable "region" {
  description = "Azure region using the programmatic name as per https://learn.microsoft.com/en-us/azure/reliability/regions-list"
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name for the cluster resources."
  type        = string
}

variable "network_resource_group" {
  description = "Azure network resource group name for the network security group."
  type        = string
}

variable "vnet_resource_group" {
  description = "Azure virtual network resource group name"
  type        = string
}

variable "subnet" {
  description = "Azure subnet name"
  type        = string
}

variable "vnet" {
  description = "Azure virtual network name"
  type        = string
}

variable "network_security_group" {
  description = "Azure network security group name"
  type        = string
}

variable "network_security_resource_group" {
  description = "Azure network security resource group name"
  type        = string
}

variable "vm_type" {
  description = "VM type for the cluster, alllowed values are `STANDARD`, `EXTRA_DENSE` and `DENSE`. `EXTRA_DENSE` is the recommended value."
  type        = string
  default     = "EXTRA_DENSE"
}

variable "user_assigned_managed_identity_name" {
  description = "User assigned managed identity name"
  type        = string
}

variable "storage_account_name" {
  description = "Azure storage account name"
  type        = string
}

variable "container_name" {
  description = "Azure storage container name"
  type        = string
}

variable "enable_immutability" {
  description = "Enable immutability for the cluster"
  type        = bool
}

