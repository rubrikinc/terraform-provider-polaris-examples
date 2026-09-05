# Example showing how to onboard an Azure subscription to RSC and manage the
# permissions for it in Azure.

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
      version = ">=1.7.0"
    }
  }
}

variable "features" {
  type = map(object({
    permission_groups = set(string)
  }))
  description = "RSC features with permission groups to enable."
}

variable "managed_identity_name" {
  type        = string
  description = "Azure user assigned managed identity name."
  default     = "terraform-managed-identity"
}

variable "sql_db_protection_managed_identity_name" {
  type        = string
  description = "Azure user assigned managed identity name."
  default     = "terraform-managed-identity-sql"
}

variable "postgres_flexible_server_protection_managed_identity_name" {
  type        = string
  description = "Azure user assigned managed identity name for the Postgres Flexible Server Protection feature."
  default     = "terraform-managed-identity-postgres"
}

variable "regions" {
  type        = set(string)
  description = "Azure regions to the RSC features for."
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

data "polaris_feature_flag" "azure_sql_tde_cmk" {
  name = "CNP_AZURE_SQL_DB_TDE_CMK_SUPPORT"
}

data "polaris_azure_permissions" "features" {
  for_each          = var.features
  feature           = each.key
  permission_groups = each.value.permission_groups
}

# Create an Azure AD application and service principal with a secret.
resource "azuread_application" "application" {
  display_name            = "RSC application - ${data.polaris_account.account.name}"
  prevent_duplicate_names = true

  web {
    homepage_url = "https://${data.polaris_account.account.fqdn}/setup_azure"
  }
}

resource "azuread_application_password" "password" {
  application_id = azuread_application.application.id
}

resource "azuread_service_principal" "service_principal" {
  client_id = azuread_application.application.client_id
}

# Create the resource group where all RSC artifacts will be stored.
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_region
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  location            = azurerm_resource_group.resource_group.location
  name                = var.managed_identity_name
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_user_assigned_identity" "sql_managed_identity" {
  count = contains(keys(var.features), "AZURE_SQL_DB_PROTECTION") && data.polaris_feature_flag.azure_sql_tde_cmk.enabled ? 1 : 0

  location            = azurerm_resource_group.resource_group.location
  name                = var.sql_db_protection_managed_identity_name
  resource_group_name = azurerm_resource_group.resource_group.name
}

# The Postgres Flexible Server Protection feature always requires a
# user-assigned managed identity, unlike SQL DB where it depends on a feature
# flag. RSC also requires the identity to be in the same resource group as the
# feature, which is why this is created in the feature's resource group.
resource "azurerm_user_assigned_identity" "postgres_managed_identity" {
  count = contains(keys(var.features), "AZURE_POSTGRES_FLEXIBLE_SERVER_PROTECTION") ? 1 : 0

  location            = azurerm_resource_group.resource_group.location
  name                = var.postgres_flexible_server_protection_managed_identity_name
  resource_group_name = azurerm_resource_group.resource_group.name
}

# Create and assign the subscription level role definition.
resource "azurerm_role_definition" "subscription" {
  for_each = data.polaris_azure_permissions.features
  name     = "Terraform - Azure Permissions Example Subscription Level - ${each.value.feature}"
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
  name     = "Terraform - Azure Permissions Example Resource Group Level - ${each.value.feature}"
  scope    = azurerm_resource_group.resource_group.id

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
  scope              = azurerm_resource_group.resource_group.id
}

# Onboard the service principal to RSC.
resource "polaris_azure_service_principal" "service_principal" {
  app_id        = azuread_application.application.client_id
  app_name      = azuread_application.application.display_name
  app_secret    = azuread_application_password.password.value
  tenant_domain = data.azuread_domains.aad_domains.domains.0.domain_name
  tenant_id     = azuread_service_principal.service_principal.application_tenant_id
}

# Onboard the subscription to RSC.
resource "polaris_azure_subscription" "subscription" {
  subscription_id   = data.azurerm_subscription.subscription.subscription_id
  subscription_name = data.azurerm_subscription.subscription.display_name
  tenant_domain     = polaris_azure_service_principal.service_principal.tenant_domain

  dynamic "cloud_native_blob_protection" {
    for_each = contains(keys(var.features), "CLOUD_NATIVE_BLOB_PROTECTION") ? [1] : []
    content {
      permission_groups = data.polaris_azure_permissions.features["CLOUD_NATIVE_BLOB_PROTECTION"].permission_groups
      permissions       = data.polaris_azure_permissions.features["CLOUD_NATIVE_BLOB_PROTECTION"].id
      regions           = var.regions
    }
  }

  dynamic "cloud_native_protection" {
    for_each = contains(keys(var.features), "CLOUD_NATIVE_PROTECTION") ? [1] : []
    content {
      permission_groups     = data.polaris_azure_permissions.features["CLOUD_NATIVE_PROTECTION"].permission_groups
      permissions           = data.polaris_azure_permissions.features["CLOUD_NATIVE_PROTECTION"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.resource_group_region
      regions               = var.regions
    }
  }

  dynamic "cloud_native_archival" {
    for_each = contains(keys(var.features), "CLOUD_NATIVE_ARCHIVAL") ? [1] : []
    content {
      permission_groups     = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL"].permission_groups
      permissions           = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.resource_group_region
      regions               = var.regions
    }
  }

  dynamic "cloud_native_archival_encryption" {
    for_each = contains(keys(var.features), "CLOUD_NATIVE_ARCHIVAL_ENCRYPTION") ? [1] : []
    content {
      permission_groups                                  = data.polaris_azure_permissions.features["CLOUD_NATIVE_ARCHIVAL_ENCRYPTION"].permission_groups
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

  dynamic "exocompute" {
    for_each = contains(keys(var.features), "EXOCOMPUTE") ? [1] : []
    content {
      permission_groups     = data.polaris_azure_permissions.features["EXOCOMPUTE"].permission_groups
      permissions           = data.polaris_azure_permissions.features["EXOCOMPUTE"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.resource_group_region
      regions               = var.regions
    }
  }

  # Unlike the other features, RSC requires both a resource group and a
  # user-assigned managed identity here, and requires the identity to be in the
  # feature's resource group. Note that the feature is also gated in RSC behind
  # the REL_ENABLE_AZURE_POSTGRES_FLEXIBLE_SERVER feature flag.
  dynamic "postgres_flexible_server_protection" {
    for_each = contains(keys(var.features), "AZURE_POSTGRES_FLEXIBLE_SERVER_PROTECTION") ? [1] : []
    content {
      permission_groups                                  = data.polaris_azure_permissions.features["AZURE_POSTGRES_FLEXIBLE_SERVER_PROTECTION"].permission_groups
      permissions                                        = data.polaris_azure_permissions.features["AZURE_POSTGRES_FLEXIBLE_SERVER_PROTECTION"].id
      regions                                            = var.regions
      resource_group_name                                = var.resource_group_name
      resource_group_region                              = var.resource_group_region
      user_assigned_managed_identity_name                = azurerm_user_assigned_identity.postgres_managed_identity[0].name
      user_assigned_managed_identity_principal_id        = azurerm_user_assigned_identity.postgres_managed_identity[0].principal_id
      user_assigned_managed_identity_region              = azurerm_user_assigned_identity.postgres_managed_identity[0].location
      user_assigned_managed_identity_resource_group_name = azurerm_user_assigned_identity.postgres_managed_identity[0].resource_group_name
    }
  }

  dynamic "sql_db_protection" {
    for_each = contains(keys(var.features), "AZURE_SQL_DB_PROTECTION") ? [1] : []
    content {
      permission_groups                                  = data.polaris_azure_permissions.features["AZURE_SQL_DB_PROTECTION"].permission_groups
      permissions                                        = data.polaris_azure_permissions.features["AZURE_SQL_DB_PROTECTION"].id
      regions                                            = var.regions
      user_assigned_managed_identity_name                = data.polaris_feature_flag.azure_sql_tde_cmk.enabled ? azurerm_user_assigned_identity.sql_managed_identity[0].name : null
      user_assigned_managed_identity_principal_id        = data.polaris_feature_flag.azure_sql_tde_cmk.enabled ? azurerm_user_assigned_identity.sql_managed_identity[0].principal_id : null
      user_assigned_managed_identity_region              = data.polaris_feature_flag.azure_sql_tde_cmk.enabled ? azurerm_user_assigned_identity.sql_managed_identity[0].location : null
      user_assigned_managed_identity_resource_group_name = data.polaris_feature_flag.azure_sql_tde_cmk.enabled ? azurerm_user_assigned_identity.sql_managed_identity[0].resource_group_name : null
    }
  }

  dynamic "sql_mi_protection" {
    for_each = contains(keys(var.features), "AZURE_SQL_MI_PROTECTION") ? [1] : []
    content {
      permission_groups = data.polaris_azure_permissions.features["AZURE_SQL_MI_PROTECTION"].permission_groups
      permissions       = data.polaris_azure_permissions.features["AZURE_SQL_MI_PROTECTION"].id
      regions           = var.regions
    }
  }

  dynamic "servers_and_apps" {
    for_each = contains(keys(var.features), "SERVERS_AND_APPS") ? [1] : []
    content {
      permission_groups     = data.polaris_azure_permissions.features["SERVERS_AND_APPS"].permission_groups
      permissions           = data.polaris_azure_permissions.features["SERVERS_AND_APPS"].id
      regions               = var.regions
      resource_group_name   = var.resource_group_name
      resource_group_region = var.resource_group_region
    }
  }

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_assignment.subscription,
    azurerm_role_assignment.resource_group,
  ]
}
