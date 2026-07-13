data "azuread_client_config" "current" {}

resource "azuread_application" "application" {
  count                   = local.create ? 1 : 0
  display_name            = coalesce(var.display_name, "Rubrik Security Cloud - Azure Protection")
  prevent_duplicate_names = true

  owners = [
    data.azuread_client_config.current.object_id,
  ]
}

resource "azuread_application_password" "password" {
  count          = local.create ? 1 : 0
  application_id = azuread_application.application[0].id
}

resource "azuread_service_principal" "service_principal" {
  count     = local.create ? 1 : 0
  client_id = azuread_application.application[0].client_id

  owners = [
    data.azuread_client_config.current.object_id,
  ]
}
