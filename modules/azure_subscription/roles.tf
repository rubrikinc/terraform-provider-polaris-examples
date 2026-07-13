# Subscription scoped role.
resource "azurerm_role_definition" "subscription" {
  for_each    = data.polaris_azure_permissions.feature
  name        = "${var.role_prefix} Subscription Role - ${each.key}"
  scope       = data.azurerm_subscription.current.id
  description = "Subscription level permissions required for Rubrik Security Cloud"

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
  for_each           = data.polaris_azure_permissions.feature
  principal_id       = var.principal_id
  role_definition_id = azurerm_role_definition.subscription[each.key].role_definition_resource_id
  scope              = data.azurerm_subscription.current.id
}

# Resource group scoped role.
resource "azurerm_role_definition" "resource_group" {
  for_each = {
    for k, v in data.polaris_azure_permissions.feature : k => v if contains(local.features_with_resource_group, k)
  }

  name        = "${var.role_prefix} Resource Group Role - ${each.key}"
  scope       = local.resource_group[each.key].id
  description = "Resource group level permissions required for Rubrik Security Cloud"

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
  for_each = {
    for k, v in data.polaris_azure_permissions.feature : k => v if contains(local.features_with_resource_group, k)
  }

  principal_id       = var.principal_id
  role_definition_id = azurerm_role_definition.resource_group[each.key].role_definition_resource_id
  scope              = local.resource_group[each.key].id
}
