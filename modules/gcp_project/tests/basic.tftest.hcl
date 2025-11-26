variable "gcp_project_id" {
  type = string
}

variables {
  project_id = var.gcp_project_id

  features = {
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC",
        "EXPORT_AND_RESTORE",
        "FILE_LEVEL_RECOVERY",
      ]
    },
    GCP_SHARED_VPC_HOST = {
      permission_groups = [
        "BASIC"
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

  # Outputs.
  assert {
    condition     = output.service_account_id == google_service_account.service_account.id
    error_message = "The service account ID output should match the ID of the service account."
  }
  assert {
    condition     = output.service_account_key == google_service_account_key.service_account.private_key
    error_message = "The service account key output should match the key of the service account."
  }
}

run "setup_random_prefix" {
  module {
    source = "./modules/random_prefix"
  }

  variables {
    prefix = "rubrik_role"
  }

  # Outputs.
  assert {
    condition     = output.result != ""
    error_message = "The random prefix output should not be empty."
  }
}

# Test GCP project onboarding.
run "gcp_project" {
  variables {
    role_id_prefix      = run.setup_random_prefix.result
    role_title_prefix   = "Rubrik Role"
    service_account_id  = run.setup_service_account.service_account_id
    service_account_key = run.setup_service_account.service_account_key
  }

  # data.google_project.
  assert {
    condition     = data.google_project.project.project_id == var.project_id
    error_message = "The project ID field should match the project ID specified."
  }
  assert {
    condition     = data.google_project.project.name != ""
    error_message = "The project name field should not be empty."
  }
  assert {
    condition     = data.google_project.project.number != ""
    error_message = "The project number field should not be empty."
  }

  # data.polaris_gcp_permissions.
  assert {
    condition     = toset(keys(data.polaris_gcp_permissions.permissions)) == toset(keys(var.features))
    error_message = "The permissions data source keys should match the RSC features specified."
  }
  assert {
    condition     = can([for v in data.polaris_gcp_permissions.permissions : regex("^[0-9a-f]{64}$", v.id)])
    error_message = "The ID field should be a SHA-256 hash."
  }
  assert {
    condition     = toset([for v in data.polaris_gcp_permissions.permissions : v.hash]) == toset([for v in data.polaris_gcp_permissions.permissions : v.id])
    error_message = "The hash field should match the ID field."
  }
  assert {
    condition     = alltrue([for k, v in data.polaris_gcp_permissions.permissions : (v.feature == k)])
    error_message = "The feature field should match the permissions data source key."
  }
  assert {
    condition     = alltrue([for k, v in data.polaris_gcp_permissions.permissions : (v.permission_groups == var.features[k].permission_groups)])
    error_message = "The permission groups field should match the permissions groups specified for the RSC feature."
  }
  assert {
    condition     = alltrue([for v in data.polaris_gcp_permissions.permissions : (v.features == null)])
    error_message = "The features field should be null."
  }
  assert {
    condition     = alltrue([for v in data.polaris_gcp_permissions.permissions : (length(v.permissions) > 0)])
    error_message = "The permissions field should have at least one permission."
  }

  # data.polaris_gcp_permissions["CLOUD_NATIVE_PROTECTION"].
  assert {
    condition     = length(data.polaris_gcp_permissions.permissions["CLOUD_NATIVE_PROTECTION"].conditions) > 0
    error_message = "The conditions field should have at least one condition."
  }
  assert {
    condition     = data.polaris_gcp_permissions.permissions["CLOUD_NATIVE_PROTECTION"].services == toset(["cloudresourcemanager.googleapis.com", "compute.googleapis.com", "storage.googleapis.com"])
    error_message = "The services field should match the expected GCP services."
  }
  assert {
    condition     = length(data.polaris_gcp_permissions.permissions["CLOUD_NATIVE_PROTECTION"].with_conditions) > 0
    error_message = "The with_conditions field should have at least one permission with conditions."
  }
  assert {
    condition     = length(data.polaris_gcp_permissions.permissions["CLOUD_NATIVE_PROTECTION"].without_conditions) > 0
    error_message = "The without_conditions field should have at least one permission without conditions."
  }

  # data.polaris_gcp_permissions["GCP_SHARED_VPC_HOST"].
  assert {
    condition     = length(data.polaris_gcp_permissions.permissions["GCP_SHARED_VPC_HOST"].conditions) == 0
    error_message = "The conditions field should not have any conditions."
  }
  assert {
    condition     = data.polaris_gcp_permissions.permissions["GCP_SHARED_VPC_HOST"].services == toset(["compute.googleapis.com"])
    error_message = "The services field should match the expected GCP services."
  }
  assert {
    condition     = length(data.polaris_gcp_permissions.permissions["GCP_SHARED_VPC_HOST"].with_conditions) == 0
    error_message = "The with_conditions field should not have any permissions with conditions."
  }
  assert {
    condition     = length(data.polaris_gcp_permissions.permissions["GCP_SHARED_VPC_HOST"].without_conditions) > 0
    error_message = "The without_conditions field should have at least one permission without conditions."
  }

  # google_project_service.
  assert {
    condition     = toset(keys(google_project_service.services)) == toset(["cloudresourcemanager.googleapis.com", "compute.googleapis.com", "storage.googleapis.com"])
    error_message = "The services resource keys should match the expected GCP services."
  }
  assert {
    condition     = one(toset([for v in google_project_service.services : v.disable_on_destroy])) == false
    error_message = "The services field should be false."
  }
  assert {
    condition     = one(toset([for v in google_project_service.services : v.project])) == var.project_id
    error_message = "The project field should match the project ID specified."
  }
  assert {
    condition     = alltrue([for k, v in google_project_service.services : (v.service == k)])
    error_message = "The service field should match the services data source key."
  }

  # polaris_gcp_project.
  assert {
    condition     = can(regex(local.uuid_regex, polaris_gcp_project.project.id)) && polaris_gcp_project.project.id != local.uuid_null
    error_message = "The ID field should be a valid non-null UUID."
  }
  assert {
    condition     = polaris_gcp_project.project.credentials == var.service_account_key
    error_message = "The credentials field should match the service account key."
  }
  assert {
    condition     = polaris_gcp_project.project.project == var.project_id
    error_message = "The project field should match the project ID specified."
  }
  assert {
    condition     = polaris_gcp_project.project.project_name == data.google_project.project.name
    error_message = "The project name field should match the project name specified."
  }
  assert {
    condition     = polaris_gcp_project.project.project_number == data.google_project.project.number
    error_message = "The project number field should match the project number specified."
  }
  assert {
    condition     = toset([for v in polaris_gcp_project.project.feature : v.name]) == toset(keys(var.features))
    error_message = "The name field of the feature block should match the RSC features specified."
  }
  assert {
    condition     = alltrue([for v in polaris_gcp_project.project.feature : (v.permission_groups == var.features[v.name].permission_groups)])
    error_message = "The permission groups field of the feature block should match the permission groups specified for the RSC feature."
  }
  assert {
    condition     = alltrue([for v in polaris_gcp_project.project.feature : (v.permissions == data.polaris_gcp_permissions.permissions[v.name].id)])
    error_message = "The permissions field of the feature block should match the ID field of the permissions data source."
  }
  assert {
    condition     = alltrue([for v in polaris_gcp_project.project.feature : (v.status == "connected")])
    error_message = "The status field of the feature block should be connected."
  }

  # data.google_service_account.
  assert {
    condition     = data.google_service_account.service_account.id == run.setup_service_account.service_account_id
    error_message = "The account ID field should match the service account ID specified."
  }
  assert {
    condition     = data.google_service_account.service_account.account_id == "rubrik-service-account"
    error_message = "The account ID field should match the service account ID specified."
  }
  assert {
    condition     = data.google_service_account.service_account.display_name == "Rubrik Service Account"
    error_message = "The name field should match the service account ID specified."
  }
  assert {
    condition     = data.google_service_account.service_account.email != ""
    error_message = "The email field should not be empty."
  }
  assert {
    condition     = data.google_service_account.service_account.member != ""
    error_message = "The member field should not be empty."
  }

  # google_project_iam_custom_role.with_conditions.
  assert {
    condition     = toset(keys(google_project_iam_custom_role.with_conditions)) == toset(["CLOUD_NATIVE_PROTECTION"])
    error_message = "The with_conditions resource keys should match the RSC features specified having permissions with conditions."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (v.role_id == "${var.role_id_prefix}_${lower(k)}")])
    error_message = "The role ID field should have the default prefix and the RSC feature name as a suffix."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (v.title == "${var.role_title_prefix} ${k}")])
    error_message = "The title field should have the default prefix and the RSC feature name as a suffix."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (toset(v.permissions) == toset(data.polaris_gcp_permissions.permissions[k].with_conditions))])
    error_message = "The permissions field should match the with_conditions field of permissions data source."
  }

  # google_project_iam_member.with_conditions.
  assert {
    condition     = length(google_project_iam_member.with_conditions) == length(google_project_iam_custom_role.with_conditions)
    error_message = "There should be one IAM member for each custom role."
  }
  assert {
    condition     = alltrue([for v in google_project_iam_member.with_conditions : (v.member == data.google_service_account.service_account.member)])
    error_message = "The member field should match the member field of the service account data source."
  }
  assert {
    condition     = alltrue([for v in google_project_iam_member.with_conditions : (v.project == var.project_id)])
    error_message = "The project field should match the project ID specified."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_member.with_conditions : (v.role == google_project_iam_custom_role.with_conditions[k].id)])
    error_message = "The role field should match the role ID of the custom role with conditions"
  }
  assert {
    condition     = alltrue([for v in google_project_iam_member.with_conditions : (length(v.condition) == 1)])
    error_message = "The condition field should have one condition."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_member.with_conditions : (endswith(v.condition[0].title, k))])
    error_message = "The title field of the condition block should have the RSC feature name as a suffix."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_member.with_conditions : (v.condition[0].expression != "")])
    error_message = "The expression field of the condition block should not be empty."
  }

  # google_project_iam_custom_role.without_conditions.
  assert {
    condition     = google_project_iam_custom_role.without_conditions.role_id == "${var.role_id_prefix}_all"
    error_message = "The role ID field should match the default role ID."
  }
  assert {
    condition     = google_project_iam_custom_role.without_conditions.title == "${var.role_title_prefix} ALL"
    error_message = "The title field should match the default title."
  }
  assert {
    condition     = toset(google_project_iam_custom_role.without_conditions.permissions) == toset(flatten([for v in data.polaris_gcp_permissions.permissions : v.without_conditions]))
    error_message = "The permissions field should match the without_conditions field of all permissions data sources."
  }

  # google_project_iam_member.without_conditions.
  assert {
    condition     = google_project_iam_member.without_conditions.member == data.google_service_account.service_account.member
    error_message = "The member field should match the member field of the service account data source."
  }
  assert {
    condition     = google_project_iam_member.without_conditions.project == var.project_id
    error_message = "The project field should match the project ID specified."
  }
  assert {
    condition     = google_project_iam_member.without_conditions.role == google_project_iam_custom_role.without_conditions.id
    error_message = "The role field should match the role ID of the custom role without conditions."
  }

  # Outputs.
  assert {
    condition     = output.cloud_account_id == polaris_gcp_project.project.id
    error_message = "The cloud account ID output should match the ID of the GCP project."
  }
  assert {
    condition     = output.cloud_account_id != local.uuid_null && can(regex(local.uuid_regex, output.cloud_account_id))
    error_message = "The cloud account ID output should be a valid UUID."
  }
}

# Test add RSC feature, remove RSC feature and update the permission groups
# of an RSC feature.
run "gcp_project_manage_features" {
  variables {
    role_id_prefix      = run.setup_random_prefix.result
    role_title_prefix   = "Rubrik Role"
    service_account_id  = run.setup_service_account.service_account_id
    service_account_key = run.setup_service_account.service_account_key

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

  # data.polaris_gcp_permissions.
  assert {
    condition     = toset(keys(data.polaris_gcp_permissions.permissions)) == toset(keys(var.features))
    error_message = "The permissions data source keys should match the RSC features specified."
  }
  assert {
    condition     = alltrue([for k, v in data.polaris_gcp_permissions.permissions : (v.feature == k)])
    error_message = "The feature field should match the permissions data source key."
  }
  assert {
    condition     = alltrue([for k, v in data.polaris_gcp_permissions.permissions : (v.permission_groups == var.features[k].permission_groups)])
    error_message = "The permission groups field should match the permissions groups specified for the RSC feature."
  }

  # polaris_gcp_project.
  assert {
    condition     = polaris_gcp_project.project.id == run.gcp_project.cloud_account_id
    error_message = "The ID field should not change when the RSC feature set is updated."
  }
  assert {
    condition     = toset([for v in polaris_gcp_project.project.feature : v.name]) == toset(keys(var.features))
    error_message = "The name field of the feature block should match the RSC features specified."
  }
  assert {
    condition     = alltrue([for v in polaris_gcp_project.project.feature : (v.permission_groups == var.features[v.name].permission_groups)])
    error_message = "The permission groups field of the feature block should match the permission groups specified for the RSC feature."
  }
  assert {
    condition     = alltrue([for v in polaris_gcp_project.project.feature : (v.permissions == data.polaris_gcp_permissions.permissions[v.name].id)])
    error_message = "The permissions field of the feature block should match the ID field of the permissions data source."
  }

  # google_project_iam_custom_role.with_conditions.
  assert {
    condition     = toset(keys(google_project_iam_custom_role.with_conditions)) == toset(["CLOUD_NATIVE_PROTECTION", "EXOCOMPUTE"])
    error_message = "The with_conditions resource keys should match the RSC features specified having permissions with conditions."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_custom_role.with_conditions : (toset(v.permissions) == toset(data.polaris_gcp_permissions.permissions[k].with_conditions))])
    error_message = "The permissions field should match the with_conditions field of permissions data source."
  }

  # google_project_iam_member.with_conditions.
  assert {
    condition     = length(google_project_iam_member.with_conditions) == length(google_project_iam_custom_role.with_conditions)
    error_message = "There should be one IAM member for each custom role."
  }
  assert {
    condition     = alltrue([for v in google_project_iam_member.with_conditions : (v.member == data.google_service_account.service_account.member)])
    error_message = "The member field should match the member field of the service account data source."
  }
  assert {
    condition     = alltrue([for k, v in google_project_iam_member.with_conditions : (v.role == google_project_iam_custom_role.with_conditions[k].id)])
    error_message = "The role field should match the role ID of the custom role with conditions"
  }

  # google_project_iam_custom_role.without_conditions.
  assert {
    condition     = google_project_iam_custom_role.without_conditions.role_id == "${var.role_id_prefix}_all"
    error_message = "The role ID field should match the default role ID."
  }
  assert {
    condition     = toset(google_project_iam_custom_role.without_conditions.permissions) == toset(flatten([for v in data.polaris_gcp_permissions.permissions : v.without_conditions]))
    error_message = "The permissions field should match the without_conditions field of all permissions data sources."
  }

  # google_project_iam_member.without_conditions.
  assert {
    condition     = google_project_iam_member.without_conditions.member == data.google_service_account.service_account.member
    error_message = "The member field should match the member field of the service account data source."
  }
  assert {
    condition     = google_project_iam_member.without_conditions.role == google_project_iam_custom_role.without_conditions.id
    error_message = "The role field should match the role ID of the custom role without conditions."
  }
}

run "rotate_service_account_key" {
  module {
    source = "./modules/service_account"
  }

  variables {
    rotation_trigger = "some-string"
  }

  # Outputs.
  assert {
    condition     = output.service_account_id == google_service_account.service_account.id
    error_message = "The service account ID output should match the ID of the service account."
  }
  assert {
    condition     = output.service_account_key == google_service_account_key.service_account.private_key
    error_message = "The service account key output should match the key of the service account."
  }
  assert {
    condition     = output.service_account_id == run.setup_service_account.service_account_id
    error_message = "The service account ID output should not change when the key is rotated."
  }
  assert {
    condition     = output.service_account_key != run.setup_service_account.service_account_key
    error_message = "The service account key output should change when the key is rotated."
  }
}

# Test updating the key of the service account onboarded to RSC.
run "gcp_project_manage_service_account" {
  variables {
    role_id_prefix      = run.setup_random_prefix.result
    role_title_prefix   = "Rubrik Role"
    service_account_id  = run.rotate_service_account_key.service_account_id
    service_account_key = run.rotate_service_account_key.service_account_key

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

  # polaris_gcp_project.
  assert {
    condition     = polaris_gcp_project.project.id == run.gcp_project.cloud_account_id
    error_message = "The ID field should not change when the RSC feature set is updated."
  }
  assert {
    condition     = polaris_gcp_project.project.credentials == var.service_account_key
    error_message = "The credentials field should match the service account key."
  }
}
