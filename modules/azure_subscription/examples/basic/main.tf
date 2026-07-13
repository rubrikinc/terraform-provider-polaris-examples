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

variable "features" {
  type = map(object({
    permission_groups = set(string)

    resource_group = optional(object({
      name = string
      tags = optional(map(string), {
        Example    = "basic"
        Module     = "azure_subscription"
        Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
      })
    }))

    user_assigned_identity = optional(object({
      name                = string
      resource_group_name = string
      tags = optional(map(string), {
        Example    = "basic"
        Module     = "azure_subscription"
        Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
      })
    }))
  }))
}

variable "region" {
  description = "Azure region for the subscription, resource groups and user assigned identities."
  type        = string
  default     = "eastus2"
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

# Create and onboard the Azure application/tenant.
module "azure_tenant" {
  source = "../../../azure_tenant"
}

# Create resource groups. Passing the exact same resource group to multiple
# features is fine.
resource "azurerm_resource_group" "resource_group" {
  for_each = {
    for v in distinct(values(var.features)[*].resource_group) : v.name => {
      tags = v.tags
    } if v != null
  }

  name     = each.key
  location = var.region
  tags     = each.value.tags
}

# Create user assigned identities. Passing the exact same user assigned identity
# to multiple features is fine.
resource "azurerm_user_assigned_identity" "identity" {
  for_each = {
    for v in distinct(values(var.features)[*].user_assigned_identity) : v.name => {
      resource_group_name = v.resource_group_name
      tags                = v.tags
    } if v != null
  }

  name                = each.key
  location            = var.region
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags

  depends_on = [
    azurerm_resource_group.resource_group,
  ]
}

# Onboard the Azure subscription.
module "azure_subscription" {
  source = "../.."

  features      = var.features
  principal_id  = module.azure_tenant.object_id
  tenant_domain = module.azure_tenant.tenant_domain

  regions = [
    var.region,
  ]

  depends_on = [
    azurerm_resource_group.resource_group,
    azurerm_user_assigned_identity.identity,
  ]
}
