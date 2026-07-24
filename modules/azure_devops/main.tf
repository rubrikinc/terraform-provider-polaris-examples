data "polaris_azure_devops_permissions" "permissions" {
  for_each          = var.features
  feature           = each.key
  permission_groups = each.value.permission_groups
}

# Generate the onboarding script. See the module README for how it is run.
data "polaris_azure_devops_script" "onboard" {
  cloud          = var.cloud
  org_native_ids = [var.native_id]
  tenant_domain  = var.tenant_domain

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value.permission_groups
    }
  }
}

# Run the onboarding script before onboarding the organization. The trigger is
# keyed on the permission versions so the script re-runs whenever RSC changes the
# permissions a feature requires, re-granting them in the organization.
# Re-running the script is safe. See the module README for details.
resource "null_resource" "onboard" {
  triggers = {
    for f, v in data.polaris_azure_devops_permissions.permissions : f => v.id
  }

  provisioner "local-exec" {
    interpreter = var.onboarding_shell == "powershell" ? ["powershell", "-Command"] : ["bash", "-c"]
    command     = var.onboarding_shell == "powershell" ? data.polaris_azure_devops_script.onboard.powershell_script : data.polaris_azure_devops_script.onboard.bash_script
  }
}

# Onboard the Azure DevOps organization to RSC.
resource "polaris_azure_devops_organization" "org" {
  native_id     = var.native_id
  tenant_domain = var.tenant_domain
  cloud         = var.cloud

  exocompute_host_type             = var.exocompute_host_type
  exocompute_region                = var.exocompute_region
  exocompute_host_cloud_account_id = var.exocompute_host_id

  storage_type         = var.storage_type
  archival_location_id = var.archival_location_id

  delete_snapshots_on_destroy = var.delete_snapshots_on_destroy

  dynamic "feature" {
    for_each = data.polaris_azure_devops_permissions.permissions
    content {
      name              = feature.key
      permission_groups = feature.value.permission_groups
      permissions       = feature.value.id
    }
  }

  depends_on = [
    null_resource.onboard,
  ]
}
