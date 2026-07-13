locals {
  # Augment the resource groups with information lookup in Azure. Features
  # having no feature specific resource group gets the default resource group.
  resource_group = {
    for k, v in var.features : k => try({
      id       = data.azurerm_resource_group.feature[k].id
      name     = v.resource_group.name
      location = data.azurerm_resource_group.feature[k].location
      tags     = v.resource_group.tags
      }, {
      id       = data.azurerm_resource_group.default[0].id
      name     = var.default_resource_group.name
      location = data.azurerm_resource_group.default[0].location
      tags     = var.default_resource_group.tags
    }, null)
  }
}

# Look up the optional default resource group.
data "azurerm_resource_group" "default" {
  count = var.default_resource_group != null ? 1 : 0
  name  = var.default_resource_group.name
}

# Look up the optional feature specific resource groups.
data "azurerm_resource_group" "feature" {
  for_each = {
    for k, v in var.features : k => v if v.resource_group != null
  }

  name = each.value.resource_group.name
}
