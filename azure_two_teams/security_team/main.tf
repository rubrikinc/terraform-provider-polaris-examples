# Example showing how to onboard an Azure service principal to RSC, independent
# of an Azure subscription.
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
      version = ">=0.8.0"
    }
  }
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

data "polaris_azure_permissions" "permissions" {
  features = [
    "CLOUD_NATIVE_PROTECTION",
  ]
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

resource "azurerm_role_definition" "role_definition" {
  name  = "RSC role definition - ${data.polaris_account.account.name}"
  scope = data.azurerm_subscription.subscription.id

  permissions {
    actions          = data.polaris_azure_permissions.permissions.actions
    data_actions     = data.polaris_azure_permissions.permissions.data_actions
    not_actions      = data.polaris_azure_permissions.permissions.not_actions
    not_data_actions = data.polaris_azure_permissions.permissions.not_data_actions
  }
}

# Note that the principal_id is the object id of the service principal.
resource "azurerm_role_assignment" "role_assignment" {
  principal_id       = azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.role_definition.role_definition_resource_id
  scope              = data.azurerm_subscription.subscription.id
}

resource "polaris_azure_service_principal" "service_principal" {
  app_id        = azuread_application.application.client_id
  app_name      = azuread_application.application.display_name
  app_secret    = azuread_service_principal_password.service_principal_secret.value
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = azuread_service_principal.service_principal.application_tenant_id
  permissions   = data.polaris_azure_permissions.permissions.id

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_definition.role_definition,
    azurerm_role_assignment.role_assignment,
  ]
}
