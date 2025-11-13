variable "project_id" {
  type = string
}

variables {
  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
      ]
    },
  }
}

provider "google" {
  project = var.project_id
}

run "setup_service_account" {
  module {
    source = "./modules/service_account"
  }
}

# Test GCP project onboarding with custom GCP role ID prefix.
run "gcp_project_with_custom_role_id_prefix" {
  variables {
    role_id_prefix      = "another_custom_id_prefix"
    service_account_id  = run.setup_service_account.service_account_id
    service_account_key = run.setup_service_account.service_account_key
  }

  # google_project_iam_custom_role.with_conditions.
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (v.role_id == "another_custom_id_prefix_${lower(k)}")])
    error_message = "The role ID field should have the custom prefix and the RSC feature name as a suffix."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (v.title == "Another Custom Id Prefix ${k}")])
    error_message = "The title field should have the custom prefix and the RSC feature name as a suffix."
  }

  # google_project_iam_custom_role.without_conditions.
  assert {
    condition     = google_project_iam_custom_role.without_conditions.role_id == "another_custom_id_prefix_all"
    error_message = "The role ID field should match the custom role ID."
  }
  assert {
    condition     = google_project_iam_custom_role.without_conditions.title == "Another Custom Id Prefix ALL"
    error_message = "The title field should match the custom title."
  }
}


# Test GCP project onboarding with custom GCP role ID and title prefixes.
run "gcp_project_with_custom_role_id_and_title_prefixes" {
  variables {
    role_id_prefix      = "custom_id_prefix"
    role_title_prefix   = "Custom Title Prefix"
    service_account_id  = run.setup_service_account.service_account_id
    service_account_key = run.setup_service_account.service_account_key
  }

  # google_project_iam_custom_role.with_conditions.
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (v.role_id == "custom_id_prefix_${lower(k)}")])
    error_message = "The role ID field should have the custom prefix and the RSC feature name as a suffix."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (v.title == "Custom Title Prefix ${k}")])
    error_message = "The title field should have the custom prefix and the RSC feature name as a suffix."
  }

  # google_project_iam_custom_role.without_conditions.
  assert {
    condition     = google_project_iam_custom_role.without_conditions.role_id == "custom_id_prefix_all"
    error_message = "The role ID field should match the custom role ID."
  }
  assert {
    condition     = google_project_iam_custom_role.without_conditions.title == "Custom Title Prefix ALL"
    error_message = "The title field should match the custom title."
  }
}

