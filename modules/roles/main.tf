resource "polaris_custom_role" "role" {
  name        = var.name
  description = var.description

  dynamic "permission" {
    for_each = var.permissions
    content {
      operation = permission.value["operation"]

      dynamic "hierarchy" {
        for_each = permission.value["hierarchy"]
        content {
          snappable_type = hierarchy.value["snappable_type"]
          object_ids     = hierarchy.value["object_ids"]
        }
      }
    }
  }
}

resource "polaris_role_assignment" "user" {
  for_each = var.user_ids

  user_id  = each.value
  role_ids = [polaris_custom_role.role.id]
}

resource "polaris_role_assignment" "sso_group" {
  for_each = var.sso_group_ids

  sso_group_id = each.value
  role_ids     = [polaris_custom_role.role.id]
}
