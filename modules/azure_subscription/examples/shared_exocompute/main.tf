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

variable "exocompute_host_id" {
  description = "RSC cloud account ID (UUID) of the Azure subscription hosting exocompute."
  type        = string
}

variable "region" {
  description = "Azure region for the subscription and resource group."
  type        = string
  default     = "eastus2"
}

variable "resource_group_name" {
  description = "Resource group name for the cloud native protection feature."
  type        = string
  default     = "rubrik-azure-subscription-example"
}

variable "tags" {
  description = "Tags to apply to Azure resources which support tags."
  type        = map(string)
  default = {
    Example    = "shared_exocompute"
    Module     = "azure_subscription"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

locals {
  features = {
    CLOUD_DISCOVERY = {
      permission_groups = [
        "BASIC",
      ]
    }
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
      resource_group = {
        name   = var.resource_group_name
        region = var.region
        tags   = var.tags
      }
    }
  }
}

# Create and onboard the Azure application/tenant.
module "azure_tenant" {
  source = "../../../azure_tenant"
}

# Create resource groups.
resource "azurerm_resource_group" "resource_group" {
  for_each = {
    for v in local.features : v.resource_group.name => {
      location = v.resource_group.region
      tags     = v.resource_group.tags
    } if try(v.resource_group, null) != null
  }

  name     = each.key
  location = each.value.location
  tags     = each.value.tags
}

# Onboard the Azure subscription as a shared exocompute application account.
module "azure_subscription" {
  source = "../.."

  features           = local.features
  exocompute_host_id = var.exocompute_host_id
  principal_id       = module.azure_tenant.object_id
  tenant_domain      = module.azure_tenant.tenant_domain

  regions = [
    var.region,
  ]

  depends_on = [
    azurerm_resource_group.resource_group,
  ]
}
