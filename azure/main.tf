# Example showing how to onboard an Azure service principal, also referred to
# as app registration or tenant, and an Azure subscription to RSC.
#
# The credentials for Azure are read from the shell environment. The RSC service
# account is read from the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment
# variable.

terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.48.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.99.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.9.0-beta.7"
    }
  }
}

variable "app_name" {
  type        = string
  description = "Azure app registration (service principal) display name."
}

variable "app_secret_name" {
  type        = string
  description = "Azure app registration client secret name."
  default     = "terraform-azure-example"
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name."
  default     = "terraform-azure-example"
}

variable "resource_group_region" {
  type        = string
  description = "Azure resource group region."
  default     = "eastus2"
}

variable "regions_to_protect" {
  type        = set(string)
  description = "Set of regions to protect."
  default     = ["eastus2"]
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

provider "polaris" {}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

# Use an existing service principal already available in the Azure AD tenant.
data "azuread_service_principal" "service_principal" {
  display_name = var.app_name
}

data "azurerm_subscription" "subscription" {}

# Create an additional secret for the principal. This will be given to RSC.
resource "azuread_service_principal_password" "service_principal_secret" {
  display_name         = var.app_secret_name
  service_principal_id = data.azuread_service_principal.service_principal.object_id
  end_date_relative    = "168h"
}

# Create the resource group where all RSC Cloud Native Protection artifacts
# will be stored.
resource "azurerm_resource_group" "cloud_native_protection" {
  name     = var.resource_group_name
  location = var.resource_group_region
}

data "polaris_azure_permissions" "cloud_native_protection" {
  feature = "CLOUD_NATIVE_PROTECTION"
}

# Create and assign the subscription level role definition.
resource "azurerm_role_definition" "subscription" {
  name  = "Terraform - Azure Example Subscription Level - Cloud Native Protection"
  scope = data.azurerm_subscription.subscription.id

  permissions {
    actions          = data.polaris_azure_permissions.cloud_native_protection.subscription_actions
    data_actions     = data.polaris_azure_permissions.cloud_native_protection.subscription_data_actions
    not_actions      = data.polaris_azure_permissions.cloud_native_protection.subscription_not_actions
    not_data_actions = data.polaris_azure_permissions.cloud_native_protection.subscription_not_data_actions
  }
}

resource "azurerm_role_assignment" "subscription" {
  principal_id       = data.azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.subscription.role_definition_resource_id
  scope              = data.azurerm_subscription.subscription.id
}

# Create and assign the resource group level role definition.
resource "azurerm_role_definition" "resource_group" {
  name  = "Terraform - Azure Example Resource Group Level - Cloud Native Protection"
  scope = azurerm_resource_group.cloud_native_protection.id

  permissions {
    actions          = data.polaris_azure_permissions.cloud_native_protection.resource_group_actions
    data_actions     = data.polaris_azure_permissions.cloud_native_protection.resource_group_data_actions
    not_actions      = data.polaris_azure_permissions.cloud_native_protection.resource_group_not_actions
    not_data_actions = data.polaris_azure_permissions.cloud_native_protection.resource_group_not_data_actions
  }
}

resource "azurerm_role_assignment" "resource_group" {
  principal_id       = data.azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.resource_group.role_definition_resource_id
  scope              = azurerm_resource_group.cloud_native_protection.id
}

resource "polaris_azure_service_principal" "tenant" {
  app_id        = data.azuread_service_principal.service_principal.client_id
  app_name      = data.azuread_service_principal.service_principal.display_name
  app_secret    = azuread_service_principal_password.service_principal_secret.value
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = data.azuread_service_principal.service_principal.application_tenant_id
}

resource "polaris_azure_subscription" "subscription" {
  subscription_id   = data.azurerm_subscription.subscription.subscription_id
  subscription_name = data.azurerm_subscription.subscription.display_name
  tenant_domain     = polaris_azure_service_principal.tenant.tenant_domain

  cloud_native_protection {
    resource_group_name   = var.resource_group_name
    resource_group_region = var.resource_group_region
    regions               = var.regions_to_protect
  }
}
