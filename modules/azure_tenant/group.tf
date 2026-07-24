# When create_exocompute_group is true, we create an EntraID group for the RSC
# Exocompute feature.

resource "azuread_group" "exocompute" {
  count            = var.create_exocompute_group ? 1 : 0
  display_name     = "${local.display_name} Exocompute Group"
  security_enabled = true

  owners = [
    data.azuread_client_config.current.object_id,
  ]
}

resource "azuread_group_member" "exocompute" {
  count            = var.create_exocompute_group ? 1 : 0
  group_object_id  = azuread_group.exocompute[0].object_id
  member_object_id = local.service_principal_object_id
}
