# Look up the customer managed key vaults. Only key vaults using Azure RBAC
# authorization are supported. RSC grants the archival encryption identity
# access to RBAC vaults automatically during onboarding.
data "azurerm_key_vault" "vault" {
  for_each = var.customer_managed_keys == null ? {} : {
    for v in var.customer_managed_keys : "${v.resource_group_name}/${v.vault_name}" => v
  }

  name                = each.value.vault_name
  resource_group_name = each.value.resource_group_name

  lifecycle {
    postcondition {
      condition     = self.rbac_authorization_enabled
      error_message = "Key vault ${self.name} must use Azure RBAC authorization. Access policy key vaults are not supported by this module."
    }
  }
}

# Look up the customer managed keys to verify they exist before creating the
# archival location.
data "azurerm_key_vault_key" "key" {
  for_each = var.customer_managed_keys == null ? {} : {
    for v in var.customer_managed_keys : "${v.resource_group_name}/${v.vault_name}/${v.name}" => v
  }

  name         = each.value.name
  key_vault_id = data.azurerm_key_vault.vault["${each.value.resource_group_name}/${each.value.vault_name}"].id
}

resource "polaris_azure_archival_location" "archival_location" {
  cloud_account_id            = var.cloud_account_id
  name                        = var.name
  network_access_type         = var.network_access_type
  redundancy                  = var.redundancy
  storage_account_name_prefix = var.storage_account_name_prefix
  storage_account_region      = var.storage_account_region
  storage_account_tags        = var.storage_account_tags
  storage_tier                = var.storage_tier

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_keys != null ? var.customer_managed_keys : []
    content {
      name       = customer_managed_key.value.name
      region     = customer_managed_key.value.region
      vault_name = customer_managed_key.value.vault_name
    }
  }

  depends_on = [
    data.azurerm_key_vault.vault,
    data.azurerm_key_vault_key.key,
  ]
}
