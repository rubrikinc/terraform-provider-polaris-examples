locals {
  # Augment the user assigned identities with information lookup in Azure.
  # Features having no feature specific user assigned identity gets the default
  # user assigned identity.
  user_assigned_identity = {
    for k, v in var.features : k => try({
      name                = v.user_assigned_identity.name
      resource_group_name = v.user_assigned_identity.resource_group_name
      location            = data.azurerm_user_assigned_identity.feature[k].location
      principal_id        = data.azurerm_user_assigned_identity.feature[k].principal_id
      }, {
      name                = var.default_user_assigned_identity.name
      resource_group_name = var.default_user_assigned_identity.resource_group_name
      location            = data.azurerm_user_assigned_identity.default[0].location
      principal_id        = data.azurerm_user_assigned_identity.default[0].principal_id
    }, null)
  }
}

# Look up the optional default user assigned identity.
data "azurerm_user_assigned_identity" "default" {
  count               = var.default_user_assigned_identity != null ? 1 : 0
  name                = var.default_user_assigned_identity.name
  resource_group_name = var.default_user_assigned_identity.resource_group_name
}

# Look up the optional feature specific user assigned identities.
data "azurerm_user_assigned_identity" "feature" {
  for_each = {
    for k, v in var.features : k => v if v.user_assigned_identity != null
  }

  name                = each.value.user_assigned_identity.name
  resource_group_name = each.value.user_assigned_identity.resource_group_name
}
