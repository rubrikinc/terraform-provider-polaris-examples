data "google_service_account" "service_account" {
  account_id = var.service_account_id
}

# Create custom roles for features having permissions with conditions and assign
# them to the service account.
resource "google_project_iam_custom_role" "with_conditions" {
  for_each = {
    for k, v in data.polaris_gcp_permissions.permissions : k => v if length(v.with_conditions) > 0
  }

  role_id     = "${var.role_id_prefix}_${lower(each.key)}"
  title       = var.role_title_prefix != null ? "${var.role_title_prefix} ${each.key}" : "${title(replace(var.role_id_prefix, "_", " "))} ${each.key}"
  permissions = each.value.with_conditions
}

resource "google_project_iam_member" "with_conditions" {
  for_each = google_project_iam_custom_role.with_conditions

  member  = data.google_service_account.service_account.member
  project = var.project_id
  role    = google_project_iam_custom_role.with_conditions[each.key].id

  condition {
    title      = "Rubrik Condition ${each.key}"
    expression = join(" || ", data.polaris_gcp_permissions.permissions[each.key].conditions)
  }
}

# Create a custom role for all permissions not having conditions and and assign
# it to the service account.
resource "google_project_iam_custom_role" "without_conditions" {
  role_id     = "${var.role_id_prefix}_all"
  title       = var.role_title_prefix != null ? "${var.role_title_prefix} ALL" : "${title(replace(var.role_id_prefix, "_", " "))} ALL"
  permissions = flatten([for v in data.polaris_gcp_permissions.permissions : v.without_conditions])
}

resource "google_project_iam_member" "without_conditions" {
  member  = data.google_service_account.service_account.member
  project = var.project_id
  role    = google_project_iam_custom_role.without_conditions.id
}
