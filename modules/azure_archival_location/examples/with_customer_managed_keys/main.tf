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
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.7.0"
    }
  }
}

variable "key_name" {
  description = "Name of the key to create in the key vault."
  type        = string
  default     = "rubrik-archival-key"
}

variable "key_vault_name" {
  description = "Name of the key vault to create. Key vault names must be globally unique."
  type        = string
  default     = "rubrik-archival-kv"
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
    Example    = "with_customer_managed_keys"
    Module     = "azure_archival_location"
    Repository = "github.com/rubrikinc/terraform-provider-polaris-examples"
  }
}

variable "user_assigned_identity_name" {
  description = "Name of the user assigned identity used by the archival encryption feature."
  type        = string
  default     = "rubrik-azure-archival-example"
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
    CLOUD_NATIVE_ARCHIVAL_ENCRYPTION = {
      permission_groups = [
        "BASIC",
      ]
      resource_group = {
        name = var.resource_group_name
        tags = var.tags
      }
      user_assigned_identity = {
        name                = azurerm_user_assigned_identity.encryption.name
        resource_group_name = azurerm_user_assigned_identity.encryption.resource_group_name
        tags                = var.tags
      }
    }
  }
}

# Create and onboard the Azure application/tenant.
module "azure_tenant" {
  source = "../../../azure_tenant"
}

# Create the resource group required by the cloud native archival features.
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.region
  tags     = var.tags
}

# Create the user assigned identity used by the archival encryption feature. RSC
# grants this identity access to the RBAC key vaults during onboarding, which is
# why this module does not perform any key vault grants itself.
resource "azurerm_user_assigned_identity" "encryption" {
  name                = var.user_assigned_identity_name
  location            = var.region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Onboard the Azure subscription with the cloud native archival and archival
# encryption features.
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
    azurerm_user_assigned_identity.encryption,
  ]
}

# Create an RBAC key vault and key for customer managed encryption.
module "key_vault" {
  source = "../../modules/key_vault"

  key_vault_name      = var.key_vault_name
  key_name            = var.key_name
  resource_group_name = var.resource_group_name
  location            = var.region
  tags                = var.tags
}

# Create an RSC archival location with customer managed keys. This example
# enables customer managed keys for a specific region. If the
# storage_account_region field is not specified, a customer managed key block
# for each source region must be specified. Source regions not having a customer
# managed key block will have its data encrypted with platform managed keys.
module "azure_archival_location" {
  source = "../.."

  cloud_account_id            = module.azure_subscription.cloud_account_id
  name                        = var.name
  storage_account_name_prefix = var.storage_account_name_prefix
  storage_account_region      = var.region
  storage_account_tags        = var.tags
  storage_tier                = "COOL"

  customer_managed_keys = [{
    name                = module.key_vault.key_name
    region              = var.region
    vault_name          = module.key_vault.key_vault_name
    resource_group_name = module.key_vault.resource_group_name
  }]

  depends_on = [
    module.key_vault,
  ]
}

# A basic form of lifecycle protection to prevent accidental deletion of the key
# vault and key. To remove the protection, set prevent_destroy to false.
resource "null_resource" "prevent_destroy" {
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    module.key_vault,
  ]
}
