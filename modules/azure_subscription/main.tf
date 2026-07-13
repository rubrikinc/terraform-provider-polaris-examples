locals {
  # Augmented version of the features variable containing additional information
  # looked up in Azure.
  features = {
    for k, v in var.features : k => {
      permissions            = data.polaris_azure_permissions.feature[k].id
      permission_groups      = v.permission_groups
      resource_group         = local.resource_group[k]
      user_assigned_identity = local.user_assigned_identity[k]
    }
  }
}

data "azurerm_subscription" "current" {}

data "polaris_azure_permissions" "feature" {
  for_each          = var.features
  feature           = each.key
  permission_groups = each.value.permission_groups
}

# Onboard the Azure subscription to RSC. Note, RSC features not accepting a
# resource group as a parameter gets neither the specified resource group or
# the default resource group. The same is true for user assigned identities.
resource "polaris_azure_subscription" "subscription" {
  subscription_id   = data.azurerm_subscription.current.subscription_id
  subscription_name = data.azurerm_subscription.current.display_name
  tenant_domain     = var.tenant_domain

  dynamic "cloud_discovery" {
    for_each = try([local.features["CLOUD_DISCOVERY"]], [])
    content {
      permissions       = cloud_discovery.value.permissions
      permission_groups = cloud_discovery.value.permission_groups
      regions           = var.regions
    }
  }

  dynamic "cloud_native_archival" {
    for_each = try([local.features["CLOUD_NATIVE_ARCHIVAL"]], [])
    content {
      permissions           = cloud_native_archival.value.permissions
      permission_groups     = cloud_native_archival.value.permission_groups
      resource_group_name   = cloud_native_archival.value.resource_group.name
      resource_group_region = cloud_native_archival.value.resource_group.location
      resource_group_tags   = cloud_native_archival.value.resource_group.tags
      regions               = var.regions
    }
  }

  dynamic "cloud_native_archival_encryption" {
    for_each = try([local.features["CLOUD_NATIVE_ARCHIVAL_ENCRYPTION"]], [])
    content {
      permissions                                        = cloud_native_archival_encryption.value.permissions
      permission_groups                                  = cloud_native_archival_encryption.value.permission_groups
      resource_group_name                                = cloud_native_archival_encryption.value.resource_group.name
      resource_group_region                              = cloud_native_archival_encryption.value.resource_group.location
      resource_group_tags                                = cloud_native_archival_encryption.value.resource_group.tags
      regions                                            = var.regions
      user_assigned_managed_identity_name                = cloud_native_archival_encryption.value.user_assigned_identity.name
      user_assigned_managed_identity_principal_id        = cloud_native_archival_encryption.value.user_assigned_identity.principal_id
      user_assigned_managed_identity_region              = cloud_native_archival_encryption.value.user_assigned_identity.location
      user_assigned_managed_identity_resource_group_name = cloud_native_archival_encryption.value.user_assigned_identity.resource_group_name
    }
  }

  dynamic "cloud_native_blob_protection" {
    for_each = try([local.features["CLOUD_NATIVE_BLOB_PROTECTION"]], [])
    content {
      permissions       = cloud_native_blob_protection.value.permissions
      permission_groups = cloud_native_blob_protection.value.permission_groups
      regions           = var.regions
    }
  }

  dynamic "cloud_native_protection" {
    for_each = try([local.features["CLOUD_NATIVE_PROTECTION"]], [])
    content {
      permissions           = cloud_native_protection.value.permissions
      permission_groups     = cloud_native_protection.value.permission_groups
      resource_group_name   = cloud_native_protection.value.resource_group.name
      resource_group_region = cloud_native_protection.value.resource_group.location
      resource_group_tags   = cloud_native_protection.value.resource_group.tags
      regions               = var.regions
    }
  }


  dynamic "exocompute" {
    for_each = try([local.features["EXOCOMPUTE"]], [])
    content {
      permissions           = exocompute.value.permissions
      permission_groups     = exocompute.value.permission_groups
      resource_group_name   = exocompute.value.resource_group.name
      resource_group_region = exocompute.value.resource_group.location
      resource_group_tags   = exocompute.value.resource_group.tags
      regions               = var.regions
    }
  }

  dynamic "servers_and_apps" {
    for_each = try([local.features["SERVERS_AND_APPS"]], [])
    content {
      permissions           = servers_and_apps.value.permissions
      permission_groups     = servers_and_apps.value.permission_groups
      resource_group_name   = servers_and_apps.value.resource_group.name
      resource_group_region = servers_and_apps.value.resource_group.location
      resource_group_tags   = servers_and_apps.value.resource_group.tags
      regions               = var.regions
    }
  }

  dynamic "sql_db_protection" {
    for_each = try([local.features["AZURE_SQL_DB_PROTECTION"]], [])
    content {
      permissions                                        = sql_db_protection.value.permissions
      permission_groups                                  = sql_db_protection.value.permission_groups
      resource_group_name                                = sql_db_protection.value.resource_group.name
      resource_group_region                              = sql_db_protection.value.resource_group.location
      resource_group_tags                                = sql_db_protection.value.resource_group.tags
      regions                                            = var.regions
      user_assigned_managed_identity_name                = sql_db_protection.value.user_assigned_identity.name
      user_assigned_managed_identity_principal_id        = sql_db_protection.value.user_assigned_identity.principal_id
      user_assigned_managed_identity_region              = sql_db_protection.value.user_assigned_identity.location
      user_assigned_managed_identity_resource_group_name = sql_db_protection.value.user_assigned_identity.resource_group_name
    }
  }

  dynamic "sql_mi_protection" {
    for_each = try([local.features["AZURE_SQL_MI_PROTECTION"]], [])
    content {
      permissions       = sql_mi_protection.value.permissions
      permission_groups = sql_mi_protection.value.permission_groups
      regions           = var.regions
    }
  }

  # This resource must explicitly depend on the role definition and the role
  # assignment so that the role is updated before RSC is notified.
  depends_on = [
    azurerm_role_assignment.subscription,
    azurerm_role_assignment.resource_group,
  ]
}

# Give RSC some time to finalize the Azure subscription onboarding.
resource "time_sleep" "wait_for_rsc" {
  create_duration = "15s"

  depends_on = [
    polaris_azure_subscription.subscription,
  ]
}
