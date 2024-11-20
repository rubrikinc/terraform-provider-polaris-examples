// Create roles for the subscription and resource group levels.

resource "azurerm_role_definition" "subscription" {
  for_each = data.polaris_azure_permissions.features
  name     = "RSC role - ${each.value.feature} - Subscription Level"
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
  principal_id       = var.principal_id
  role_definition_id = azurerm_role_definition.subscription[each.key].role_definition_resource_id
  scope              = data.azurerm_subscription.subscription.id
}

resource "azurerm_role_definition" "resource_group" {
  for_each = data.polaris_azure_permissions.features
  name     = "RSC role - ${each.value.feature} - Resource Group Level"
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
  principal_id       = var.principal_id
  role_definition_id = azurerm_role_definition.resource_group[each.key].role_definition_resource_id
  scope              = azurerm_resource_group.resource_group.id
}
