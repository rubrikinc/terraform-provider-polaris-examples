data "polaris_gcp_project" "project" {
  id = var.cloud_account_id

  lifecycle {
    postcondition {
      condition     = contains([for f in self.feature : f.name], "EXOCOMPUTE")
      error_message = "The cloud account must have the EXOCOMPUTE RSC feature enabled."
    }

    postcondition {
      condition     = !contains([for f in self.feature : f.permission_groups if f.name == "EXOCOMPUTE"], "AUTOMATED_NETWORKING_SETUP")
      error_message = "The EXOCOMPUTE RSC feature must not have the AUTOMATED_NETWORKING_SETUP permission group enabled."
    }
  }
}

resource "polaris_gcp_exocompute" "exocompute" {
  cloud_account_id     = var.cloud_account_id
  trigger_health_check = var.trigger_health_check

  dynamic "regional_config" {
    for_each = var.regional_configs
    content {
      region      = regional_config.value.region
      subnet_name = regional_config.value.subnet_name
      vpc_name    = regional_config.value.vpc_name
    }
  }
}
