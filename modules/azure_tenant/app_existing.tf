data "azuread_application" "application" {
  count     = local.create ? 0 : 1
  client_id = var.app_id
}

data "azuread_service_principal" "service_principal" {
  count     = local.create ? 0 : 1
  client_id = var.app_id
}
