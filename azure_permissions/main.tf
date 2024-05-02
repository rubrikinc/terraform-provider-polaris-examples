# Example showing how to onboard an Azure subscription with a specific feature
# and Terraform permissions management.
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
      version = "=0.9.0-beta.2"
    }
  }
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name."
}

variable "resource_group_region" {
  type        = string
  description = "Azure resource group region."
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

provider "polaris" {}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

data "azurerm_subscription" "subscription" {}

data "polaris_account" "account" {}

data "polaris_azure_permissions" "cloud_native_protection" {
  feature = "CLOUD_NATIVE_PROTECTION"
}

resource "azuread_application" "application" {
  display_name = "RSC application - ${data.polaris_account.account.name}"
  web {
    homepage_url = "https://${data.polaris_account.account.fqdn}/setup_azure"
  }
}

resource "azuread_service_principal" "service_principal" {
  client_id = azuread_application.application.client_id
}

resource "azuread_service_principal_password" "service_principal_secret" {
  service_principal_id = azuread_service_principal.service_principal.object_id
}

# Create the resource group where all artifacts from the Cloud Native Protection
# feature will be stored.
resource "azurerm_resource_group" "cloud_native_protection" {
  name     = var.resource_group_name
  location = var.resource_group_region
}

# Create and assign the subscription level role definition.
resource "azurerm_role_definition" "subscription" {
  name  = "Terraform - ${data.polaris_account.account.name} - Subscription Level"
  scope = data.azurerm_subscription.subscription.id

  permissions {
    actions          = data.polaris_azure_permissions.cloud_native_protection.subscription_actions
    data_actions     = data.polaris_azure_permissions.cloud_native_protection.subscription_data_actions
    not_actions      = data.polaris_azure_permissions.cloud_native_protection.subscription_not_actions
    not_data_actions = data.polaris_azure_permissions.cloud_native_protection.subscription_not_data_actions
  }
}

resource "azurerm_role_assignment" "subscription" {
  principal_id       = azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.subscription.role_definition_resource_id
  scope              = data.azurerm_subscription.subscription.id
}

# Create and assign the resource group level role definition.
resource "azurerm_role_definition" "resource_group" {
  name  = "Terraform - ${data.polaris_account.account.name} - Resource Group Level"
  scope = azurerm_resource_group.cloud_native_protection.id

  permissions {
    actions          = data.polaris_azure_permissions.cloud_native_protection.resource_group_actions
    data_actions     = data.polaris_azure_permissions.cloud_native_protection.resource_group_data_actions
    not_actions      = data.polaris_azure_permissions.cloud_native_protection.resource_group_not_actions
    not_data_actions = data.polaris_azure_permissions.cloud_native_protection.resource_group_not_data_actions
  }
}

resource "azurerm_role_assignment" "resource_group" {
  principal_id       = azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.resource_group.role_definition_resource_id
  scope              = azurerm_resource_group.cloud_native_protection.id
}

# Onboard the service principal to RSC.
resource "polaris_azure_service_principal" "service_principal" {
  app_id        = azuread_application.application.client_id
  app_name      = azuread_application.application.display_name
  app_secret    = azuread_service_principal_password.service_principal_secret.value
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = azuread_service_principal.service_principal.application_tenant_id
}

# Onboard the subscription to RSC.
resource "polaris_azure_subscription" "subscription" {
  subscription_id   = data.azurerm_subscription.subscription.subscription_id
  subscription_name = data.azurerm_subscription.subscription.display_name
  tenant_domain     = polaris_azure_service_principal.service_principal.tenant_domain

  cloud_native_protection {
    permissions           = data.polaris_azure_permissions.cloud_native_protection.id
    resource_group_name   = azurerm_resource_group.cloud_native_protection.name
    resource_group_region = azurerm_resource_group.cloud_native_protection.location

    regions = [
      "eastus2",
    ]
  }

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_definition.subscription,
    azurerm_role_definition.resource_group,
  ]
}
