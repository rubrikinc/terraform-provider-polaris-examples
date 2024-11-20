// Onboard subscription.

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}

data "azurerm_subscription" "subscription" {
  subscription_id = var.subscription_id
}

data "polaris_azure_permissions" "features" {
  for_each = var.features
  feature  = each.key
}

# Create the resource group where all RSC artifacts will be stored.
resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group_name
  location = var.resource_group_region
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  location            = azurerm_resource_group.resource_group.location
  name                = "rsc-managed-identity"
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "polaris_azure_subscription" "subscription" {
  subscription_id   = var.subscription_id
  subscription_name = data.azurerm_subscription.subscription.display_name
  tenant_domain     = var.tenant_domain

  dynamic "cloud_native_blob_protection" {
    for_each = contains(var.features, "CLOUD_NATIVE_BLOB_PROTECTION") ? [1] : []
    content {
      permissions = data.polaris_azure_permissions.features["CLOUD_NATIVE_BLOB_PROTECTION"].id
      regions     = var.regions
    }
  }

  dynamic "cloud_native_protection" {
    for_each = contains(var.features, "CLOUD_NATIVE_PROTECTION") ? [1] : []
    content {
      permissions           = data.polaris_azure_permissions.features["CLOUD_NATIVE_PROTECTION"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.resource_group_region
      regions               = var.regions
    }
  }

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

  dynamic "exocompute" {
    for_each = contains(var.features, "EXOCOMPUTE") ? [1] : []
    content {
      permissions           = data.polaris_azure_permissions.features["EXOCOMPUTE"].id
      resource_group_name   = var.resource_group_name
      resource_group_region = var.resource_group_region
      regions               = var.regions
    }
  }

  dynamic "sql_db_protection" {
    for_each = contains(var.features, "AZURE_SQL_DB_PROTECTION") ? [1] : []
    content {
      permissions = data.polaris_azure_permissions.features["AZURE_SQL_DB_PROTECTION"].id
      regions     = var.regions
    }
  }

  dynamic "sql_mi_protection" {
    for_each = contains(var.features, "AZURE_SQL_MI_PROTECTION") ? [1] : []
    content {
      permissions = data.polaris_azure_permissions.features["AZURE_SQL_MI_PROTECTION"].id
      regions     = var.regions
    }
  }

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_definition.subscription,
    azurerm_role_definition.resource_group,
  ]
}
