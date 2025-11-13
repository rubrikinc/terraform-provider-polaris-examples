test {
  parallel = true
}

variables {
  project_id          = null
  service_account_id  = null
  service_account_key = null
}

run "variables_are_null" {
  command = plan

  variables {
    features = null
  }

  expect_failures = [
    var.features,
    var.project_id,
    var.service_account_id,
    var.service_account_key,
  ]
}

run "variables_are_empty" {
  command = plan

  variables {
    features            = {}
    project_id          = ""
    service_account_id  = ""
    service_account_key = ""
  }

  expect_failures = [
    var.features,
    var.project_id,
    var.service_account_id,
    var.service_account_key,
  ]
}

run "features_invalid_name" {
  command = plan

  variables {
    features = {
      CLOWN_NATIVE_PROTECTION = {
        permission_groups = [
          "BASIC",
        ]
      }
    }
  }

  expect_failures = [
    var.features,
    var.project_id,
    var.service_account_id,
    var.service_account_key,
  ]
}

run "features_invalid_permission_group" {
  command = plan

  variables {
    features = {
      CLOUD_NATIVE_ARCHIVAL = {
        permission_groups = [
          "BASIC",
          "EXPORT_AND_RESTORE",
        ]
      }
    }
  }

  expect_failures = [
    var.features,
    var.project_id,
    var.service_account_id,
    var.service_account_key,
  ]
}
