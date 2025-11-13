data "google_project" "project" {
  project_id = var.project_id
}

# Lookup the required permissions for each RSC feature.
data "polaris_gcp_permissions" "permissions" {
  for_each          = var.features
  feature           = each.key
  permission_groups = each.value.permission_groups
}

# Enable all services required by the RSC features.
resource "google_project_service" "services" {
  for_each = toset(flatten([
    for v in data.polaris_gcp_permissions.permissions : v.services
  ]))

  disable_on_destroy = false
  project            = var.project_id
  service            = each.key
}

# Onboard the GCP project to RSC.
resource "polaris_gcp_project" "project" {
  credentials       = var.service_account_key
  project           = var.project_id
  project_name      = data.google_project.project.name
  project_number    = data.google_project.project.number
  organization_name = var.organization_name

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value.permission_groups
      permissions       = data.polaris_gcp_permissions.permissions[feature.key].id
    }
  }

  # Explicitly depend on the role memberships to make sure this resource
  # is destroyed before the roles are destroyed.
  depends_on = [
    google_project_iam_member.with_conditions,
    google_project_iam_member.without_conditions,
    google_project_service.services,
  ]
}

# Give RSC some time to finalize the GCP project onboarding.
resource "time_sleep" "wait_for_rsc" {
  create_duration = "20s"

  depends_on = [
    polaris_gcp_project.project,
  ]
}
