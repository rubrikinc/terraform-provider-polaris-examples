# Generate the onboarding script. See the module README for how it is run.
data "polaris_azure_devops_script" "onboard" {
  cloud_type     = var.cloud_type
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

# Optionally run the onboarding script before onboarding the organization. The
# trigger is keyed on the organization, not the script, because the script is
# not idempotent. See the module README for details.
resource "null_resource" "onboard" {
  count = var.run_onboarding_script != null ? 1 : 0

  triggers = {
    native_id = var.native_id
  }

  provisioner "local-exec" {
    interpreter = var.run_onboarding_script == "powershell" ? ["powershell", "-Command"] : ["bash", "-c"]
    command     = var.run_onboarding_script == "powershell" ? data.polaris_azure_devops_script.onboard.powershell_script : data.polaris_azure_devops_script.onboard.bash_script
  }
}

# Onboard the Azure DevOps organization to RSC.
resource "polaris_azure_devops_organization" "org" {
  native_id     = var.native_id
  tenant_domain = var.tenant_domain
  cloud_type    = var.cloud_type

  host_type                   = var.exocompute_host_type
  exocompute_region           = var.exocompute_region
  exocompute_cloud_account_id = var.exocompute_host_id

  storage_type       = var.storage_type
  backup_location_id = var.archival_location_id

  delete_snapshots_on_destroy = var.delete_snapshots_on_destroy

  dynamic "feature" {
    for_each = var.features
    content {
      name              = feature.key
      permission_groups = feature.value.permission_groups
    }
  }

  depends_on = [
    null_resource.onboard,
  ]
}
