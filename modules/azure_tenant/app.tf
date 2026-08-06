# When create_app is true we create a new application with the specified
# display_name, otherwise we look up an already existing application.

locals {
  service_principal_object_id = local.create_app ? azuread_service_principal.service_principal[0].object_id : data.azuread_service_principal.service_principal[0].object_id
}

data "azuread_application" "application" {
  count     = local.create_app ? 0 : 1
  client_id = var.app_id
}

data "azuread_service_principal" "service_principal" {
  count     = local.create_app ? 0 : 1
  client_id = var.app_id
}

resource "azuread_application" "application" {
  count                   = local.create_app ? 1 : 0
  display_name            = local.display_name
  prevent_duplicate_names = true

  owners = [
    data.azuread_client_config.current.object_id,
  ]
}

resource "azuread_application_password" "password" {
  count          = local.create_app ? 1 : 0
  application_id = azuread_application.application[0].id
}

resource "azuread_service_principal" "service_principal" {
  count     = local.create_app ? 1 : 0
  client_id = azuread_application.application[0].client_id

  owners = [
    data.azuread_client_config.current.object_id,
  ]

  depends_on = [
    azuread_application_password.password,
  ]
}
