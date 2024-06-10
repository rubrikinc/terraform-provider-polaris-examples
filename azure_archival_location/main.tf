# Example showing how to onboard an Azure subscription with the Cloud Native
# Archival and Cloud Native Archival Encryption features and create an archival
# location.
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

variable "archival_location_name" {
  type        = string
  description = "Name of the archival location."
  default     = "Azure Archival Location"
}

variable "features" {
  type        = set(string)
  description = "List of features to enable."
  default     = ["CLOUD_NATIVE_ARCHIVAL", "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION"]
}

variable "managed_identity_name" {
  type        = string
  description = "Azure user assigned managed identity name."
  default     = "terraform-managed-identity"
}

variable "regions" {
  type        = set(string)
  description = "List of regions to enable."
  default     = ["eastus2"]
}

variable "resource_group_name" {
  type        = string
  description = "Azure resource group name."
  default     = "terraform-azure-permissions-example"
}

variable "resource_group_region" {
  type        = string
  description = "Azure resource group region."
  default     = "eastus2"
}

variable "storage_account_name_prefix" {
  type        = string
  description = "Azure storage account name prefix."
  default     = "archival"
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

data "polaris_azure_permissions" "features" {
  for_each = var.features
  feature  = each.key
}

# Create an Azure AD application and service principal with a secret.
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

# Create the resource group where all RSC artifacts will be stored.
resource "azurerm_resource_group" "default" {
  name     = var.resource_group_name
  location = var.resource_group_region
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  location            = azurerm_resource_group.default.location
  name                = var.managed_identity_name
  resource_group_name = azurerm_resource_group.default.name
}

# Create and assign the subscription level role definition.
resource "azurerm_role_definition" "subscription" {
  for_each = data.polaris_azure_permissions.features
  name     = "Terraform - Azure Archival Location Example Subscription Level - ${each.value.feature}"
  scope    = data.azurerm_subscription.subscription.id

  dynamic "permissions" {
    for_each = length(concat(each.value.subscription_actions, each.value.subscription_data_actions, each.value.subscription_not_actions, each.value.subscription_not_data_actions)) > 0 ? [1] : []
    content {
      actions          = each.value.subscription_actions
      data_actions     = each.value.subscription_data_actions
      not_actions      = each.value.subscription_not_actions
      not_data_actions = each.value.subscription_not_data_actions
    }
  }
}

resource "azurerm_role_assignment" "subscription" {
  for_each           = data.polaris_azure_permissions.features
  principal_id       = azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.subscription[each.key].role_definition_resource_id
  scope              = data.azurerm_subscription.subscription.id
}

# Create and assign the resource group level role definition.
resource "azurerm_role_definition" "resource_group" {
  for_each = data.polaris_azure_permissions.features
  name     = "Terraform - Azure Archival Location Example Resource Group Level - ${each.value.feature}"
  scope    = azurerm_resource_group.default.id

  dynamic "permissions" {
    for_each = length(concat(each.value.resource_group_actions, each.value.resource_group_data_actions, each.value.resource_group_not_actions, each.value.resource_group_not_data_actions)) > 0 ? [1] : []
    content {
      actions          = each.value.resource_group_actions
      data_actions     = each.value.resource_group_data_actions
      not_actions      = each.value.resource_group_not_actions
      not_data_actions = each.value.resource_group_not_data_actions
    }
  }
}

resource "azurerm_role_assignment" "resource_group" {
  for_each           = data.polaris_azure_permissions.features
  principal_id       = azuread_service_principal.service_principal.object_id
  role_definition_id = azurerm_role_definition.resource_group[each.key].role_definition_resource_id
  scope              = azurerm_resource_group.default.id
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

  dynamic "cloud_native_archival" {
    for_each = contains(var.features, "CLOUD_NATIVE_ARCHIVAL") ? [1] : []
    content {
      permissions           = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.resource_group_region
      regions               = var.regions
    }
  }

  dynamic "cloud_native_archival_encryption" {
    for_each = contains(var.features, "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION") ? [1] : []
    content {
      permissions                                        = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL_ENCRYPTION"].id
      resource_group_name                                = var.resource_group_name
      resource_group_region                              = var.resource_group_region
      regions                                            = var.regions
      user_assigned_managed_identity_name                = azurerm_user_assigned_identity.managed_identity.name
      user_assigned_managed_identity_principal_id        = azurerm_user_assigned_identity.managed_identity.principal_id
      user_assigned_managed_identity_region              = azurerm_user_assigned_identity.managed_identity.location
      user_assigned_managed_identity_resource_group_name = azurerm_user_assigned_identity.managed_identity.resource_group_name
    }
  }

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_definition.subscription,
    azurerm_role_definition.resource_group,
  ]
}

# Create a source region archival location.
resource "polaris_azure_archival_location" "archival_location" {
  cloud_account_id            = polaris_azure_subscription.subscription.id
  name                        = var.archival_location_name
  storage_account_name_prefix = var.storage_account_name_prefix
}
