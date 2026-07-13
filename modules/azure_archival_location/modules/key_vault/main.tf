data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                       = var.key_vault_name
  location                   = var.location
  purge_protection_enabled   = var.purge_protection_enabled
  rbac_authorization_enabled = true
  resource_group_name        = var.resource_group_name
  sku_name                   = var.sku_name
  tags                       = var.tags
  tenant_id                  = data.azurerm_client_config.current.tenant_id
}

# Grant the current credentials the data plane role required to create the key.
# RBAC key vaults do not honor access policies, so the key cannot be created
# without a Key Vault Crypto Officer role assignment.
resource "azurerm_role_assignment" "creator" {
  count = var.grant_creator_key_permissions ? 1 : 0

  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Crypto Officer"
  scope                = azurerm_key_vault.key_vault.id
}

# Give the role assignment time to propagate before creating the key.
resource "time_sleep" "role_propagation" {
  count = var.grant_creator_key_permissions ? 1 : 0

  create_duration = var.role_propagation_delay

  depends_on = [
    azurerm_role_assignment.creator,
  ]
}

resource "azurerm_key_vault_key" "key" {
  name         = var.key_name
  key_opts     = var.key_opts
  key_size     = var.key_size
  key_type     = var.key_type
  key_vault_id = azurerm_key_vault.key_vault.id
  tags         = var.tags

  depends_on = [
    azurerm_role_assignment.creator,
    time_sleep.role_propagation,
  ]
}
