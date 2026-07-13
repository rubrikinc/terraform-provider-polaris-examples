terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.48.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.7.0"
    }
  }
}

variable "name" {
  description = "Name of the RSC archival location."
  type        = string
  default     = "archival-location"
}

variable "region" {
  description = "Azure region for the subscription, resource group and archival location."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Resource group name for the cloud native archival feature."
  type        = string
  default     = "rubrik-azure-archival-example"
}

variable "storage_account_name_prefix" {
  description = "Azure storage account name prefix. Can only consist of lower case letters and numbers."
  type        = string
  default     = "rubrikarchival"
}

variable "tags" {
  description = "Tags to apply to Azure resources which support tags."
  type        = map(string)
  default = {
    Example    = "basic"
    Module     = "azure_archival_location"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

locals {
  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC",
      ]
      resource_group = {
        name = var.resource_group_name
        tags = var.tags
      }
    }
  }
}

# Create and onboard the Azure application/tenant.
module "azure_tenant" {
  source = "../../../azure_tenant"
}

# Create the resource group required by the cloud native archival feature.
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.tags
}

# Onboard the Azure subscription with the cloud native archival feature.
module "azure_subscription" {
  source = "../../../azure_subscription"

  features      = local.features
  principal_id  = module.azure_tenant.object_id
  tenant_domain = module.azure_tenant.tenant_domain

  regions = [
    var.region,
  ]

  depends_on = [
    azurerm_resource_group.resource_group,
  ]
}

# Create an RSC archival location.
module "azure_archival_location" {
  source = "../.."

  cloud_account_id            = module.azure_subscription.cloud_account_id
  name                        = var.name
  storage_account_name_prefix = var.storage_account_name_prefix
  storage_account_region      = var.region
  storage_account_tags        = var.tags
  storage_tier                = "COOL"
}
