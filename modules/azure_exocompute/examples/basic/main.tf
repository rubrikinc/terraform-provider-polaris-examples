terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.48.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.99.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.7.0"
    }
  }
}

variable "region" {
  description = "Azure region for the subscription, resource group and exocompute cluster."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Resource group name for the cloud native protection and exocompute features."
  type        = string
  default     = "rubrik-azure-exocompute-example"
}

variable "tags" {
  description = "Tags to apply to Azure resources which support tags."
  type        = map(string)
  default = {
    Example    = "basic"
    Module     = "azure_exocompute"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

variable "subnet_id" {
  description = "Azure subnet ID for the exocompute cluster."
  type        = string
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

locals {
  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    }
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
      ]
    }
  }
}

# Create and onboard the Azure application/tenant.
module "azure_tenant" {
  source = "../../../azure_tenant"
}

# Create the resource group required by the cloud native features.
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.tags
}

# Onboard the Azure subscription.
module "azure_subscription" {
  source = "../../../azure_subscription"

  features      = local.features
  principal_id  = module.azure_tenant.object_id
  tenant_domain = module.azure_tenant.tenant_domain

  default_resource_group = {
    name = var.resource_group_name
    tags = var.tags
  }

  regions = [
    var.region,
  ]

  depends_on = [
    azurerm_resource_group.resource_group,
  ]
}

# Configure exocompute for the onboarded subscription.
module "azure_exocompute" {
  source = "../.."

  cloud_account_id         = module.azure_subscription.cloud_account_id
  pod_overlay_network_cidr = "10.244.0.0/16"
  region                   = var.region
  subnet_id                = var.subnet_id
}
