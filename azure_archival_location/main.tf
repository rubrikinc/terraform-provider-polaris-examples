# Example showing how to create an Azure cloud native archival location for a
# onboarded Azure subscription. See the azure example for how to onboard an
# Azure subscription with the CLOUD_NATIVE_ARCHIVAL and
# CLOUD_NATIVE_ARCHIVAL_ENCRYPTION features.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
}

variable "cloud_account_id" {
  type        = string
  description = "RSC cloud account ID of the Azure subscription."
}

variable "archival_location_name" {
  type        = string
  description = "Archival location name."
  default     = "My Archival Location"
}

variable "storage_account_name_prefix" {
  type        = string
  description = "Azure storage account name prefix."
  default     = "archival"
}

provider "polaris" {}

resource "polaris_azure_archival_location" "archival_location" {
  cloud_account_id            = var.cloud_account_id
  name                        = var.archival_location_name
  storage_account_name_prefix = var.storage_account_name_prefix
}
