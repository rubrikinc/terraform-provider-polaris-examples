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
      version = "~>2.4.8"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.99.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

variable "application_id" {
  type        = string
  description = "Azure application ID. Also known as client ID."
}

variable "application_secret" {
  type        = string
  description = "Azure application secret. Also known as client secret."
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

provider "polaris" {}

data "azuread_domains" "aad_domains" {
  only_initial = true
}

data "azuread_application" "application" {
  client_id = var.application_id
}

data "azuread_service_principal" "service_principal" {
  client_id = var.application_id
}

data "azurerm_subscription" "subscription" {}

data "polaris_azure_permissions" "permissions" {
  features = [
    "CLOUD_NATIVE_PROTECTION",
  ]
}

resource "azurerm_role_definition" "default" {
  name  = "Terraform"
  scope = data.azurerm_subscription.subscription.id

  permissions {
    actions          = data.polaris_azure_permissions.permissions.actions
    data_actions     = data.polaris_azure_permissions.permissions.data_actions
    not_actions      = data.polaris_azure_permissions.permissions.not_actions
    not_data_actions = data.polaris_azure_permissions.permissions.not_data_actions
  }
}

# Note that the principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "default" {
  principal_id       = data.azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.default.role_definition_resource_id
  scope              = data.azurerm_subscription.subscription.id
}

resource "polaris_azure_service_principal" "service_principal" {
  app_id        = data.azuread_application.application.client_id
  app_name      = data.azuread_application.application.display_name
  app_secret    = var.application_secret
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = data.azuread_service_principal.service_principal.application_tenant_id
  permissions   = data.polaris_azure_permissions.permissions.id

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_definition.default,
    azurerm_role_assignment.default,
  ]
}

resource "polaris_azure_subscription" "default" {
  subscription_id   = data.azurerm_subscription.subscription.subscription_id
  subscription_name = data.azurerm_subscription.subscription.display_name
  tenant_domain     = polaris_azure_service_principal.service_principal.tenant_domain

  cloud_native_protection {
    regions = [
      "eastus2",
    ]
  }
}
