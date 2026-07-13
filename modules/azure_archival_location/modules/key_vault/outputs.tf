output "key_id" {
  description = "The key vault key ID."
  value       = azurerm_key_vault_key.key.id
}

output "key_name" {
  description = "The key vault key name."
  value       = azurerm_key_vault_key.key.name
}

output "key_vault_id" {
  description = "The key vault ID."
  value       = azurerm_key_vault.key_vault.id
}

output "key_vault_name" {
  description = "The key vault name."
  value       = azurerm_key_vault.key_vault.name
}

output "resource_group_name" {
  description = "The name of the resource group containing the key vault."
  value       = azurerm_key_vault.key_vault.resource_group_name
}
