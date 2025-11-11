variable "cluster_name" {
  description = "The name of the Azure cloud cluster"
  type        = string
  default     = "my-cces-cluster"
}

variable "admin_email" {
  description = "Admin email for the cluster"
  type        = string
  default     = "admin@example.com"
}

variable "admin_password" {
  description = "Admin password for the cluster"
  type        = string
  sensitive   = true
  default     = "RubrikGoForward!"
}

variable "dns_name_servers" {
  description = "List of DNS name servers"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "ntp_servers" {
  description = "List of NTP servers"
  type        = list(string)
  default     = ["pool.ntp.org"]
}

variable "num_nodes" {
  description = "Number of nodes in the cluster"
  type        = number
  default     = 3
}

variable "keep_cluster_on_failure" {
  description = "Keep cluster on failure"
  type        = bool
  default     = true
}

variable "cdm_version" {
  description = "CDM version for the cluster"
  type        = string
  default     = "9.2.3-p8-29766"
}

variable "instance_type" {
  description = "Azure instance type, Allowed values are `STANDARD_DS5_V2`, `STANDARD_D16S_V5`, `STANDARD_D8S_V5`, `STANDARD_D32S_V5`, `STANDARD_E16S_V5`, `STANDARD_D8AS_V5`, `STANDARD_D16AS_V5`, `STANDARD_D32AS_V5` and `STANDARD_E16AS_V5`"
  type        = string
  default     = "STANDARD_D8S_V5"
}

variable "region" {
  description = "Azure region"
  type        = string
  default     = "centralus"
}

variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = "my-resource-group"
}

variable "network_resource_group" {
  description = "Azure network resource group name"
  type        = string
  default     = "my-network-resource-group"
}

variable "vnet_resource_group" {
  description = "Azure virtual network resource group name"
  type        = string
  default     = "my-vnet-resource-group"
}

variable "subnet" {
  description = "Azure subnet name"
  type        = string
  default     = "my-subnet"
}

variable "vnet" {
  description = "Azure virtual network name"
  type        = string
  default     = "my-vnet"
}

variable "network_security_group" {
  description = "Azure network security group name"
  type        = string
  default     = "my-nsg"
}

variable "network_security_resource_group" {
  description = "Azure network security resource group name"
  type        = string
  default     = "my-nsg-resource-group"
}

variable "vm_type" {
  description = "VM type for the cluster"
  type        = string
  default     = "EXTRA_DENSE"
}

variable "user_assigned_managed_identity_name" {
  description = "User assigned managed identity name"
  type        = string
  default     = "my-managed-identity"
}

variable "storage_account_name" {
  description = "Azure storage account name"
  type        = string
  default     = "mystorageaccount"
}

variable "container_name" {
  description = "Azure storage container name"
  type        = string
  default     = "mycontainer"
}

variable "enable_immutability" {
  description = "Enable immutability for the cluster"
  type        = bool
  default     = false
}

