variable "gcp_project_id" {
  description = "GCP project ID."
  type        = string
}

variables {
  labels = {
    test       = "basic"
    module     = "gcp_archival_location"
    repository = "terraform-provider-polaris-examples"
  }
}

provider "google" {
  project = var.gcp_project_id
}

run "setup_service_account" {
  module {
    source = "../gcp_project/modules/service_account"
  }
}

run "setup_gcp_project" {
  module {
    source = "../gcp_project"
  }

  variables {
    project_id          = var.gcp_project_id
    service_account_id  = run.setup_service_account.service_account_id
    service_account_key = run.setup_service_account.service_account_key

    features = {
      CLOUD_NATIVE_ARCHIVAL = {
        permission_groups = [
          "BASIC",
        ]
      }
    }
  }
}

# Test create archival location without customer-managed keys.
run "archival_location" {
  variables {
    bucket_labels    = var.labels
    bucket_prefix    = "test-bucket-prefix"
    cloud_account_id = run.setup_gcp_project.cloud_account_id
    name             = "test-name"
    region           = "us-central1"
    storage_class    = "STANDARD"
  }

  # data.polaris_gcp_project.project.
  assert {
    condition     = data.polaris_gcp_project.project.id == run.setup_gcp_project.cloud_account_id
    error_message = "The ID field should match the GCP Project cloud account ID."
  }
  assert {
    condition     = data.polaris_gcp_project.project.project_id == var.project_id
    error_message = "The project ID field should match the specified project ID."
  }

  # data.google_project.project.
  assert {
    condition     = data.google_project.project.project_id == var.project_id
    error_message = "The project ID field should match the specified project ID."
  }
  assert {
    condition     = data.google_project.project.name != ""
    error_message = "The name field should not be empty."
  }
  assert {
    condition     = data.google_project.project.number != ""
    error_message = "The number field should not be empty."
  }

  # polaris_gcp_archival_location.archival_location.
  assert {
    condition     = polaris_gcp_archival_location.archival_location.cloud_account_id == run.setup_gcp_project.cloud_account_id
    error_message = "The cloud account ID field should match the onboarded GCP project cloud account ID."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.bucket_labels == var.bucket_labels
    error_message = "The bucket labels should match the specified bucket labels."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.bucket_prefix == var.bucket_prefix
    error_message = "The bucket prefix field should match the specified bucket prefix."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.name == var.name
    error_message = "The name field should match the specified name."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.region == var.region
    error_message = "The region field should match the specified region."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.storage_class == var.storage_class
    error_message = "The storage class field should match the specified storage class."
  }
  assert {
    condition     = length(polaris_gcp_archival_location.archival_location.customer_managed_key) == 0
    error_message = "The customer managed keys field should be empty."
  }

  # Outputs.
  assert {
    condition     = output.archival_location_id == polaris_gcp_archival_location.archival_location.id
    error_message = "The archival location ID output should match the ID of the archival location."
  }
  assert {
    condition     = output.archival_location_id != local.uuid_null && can(regex(local.uuid_regex, output.archival_location_id))
    error_message = "The archival location ID output should be a valid UUID."
  }
}

# Test add updating the bucket labels, name and storage class.
run "archival_location_manage" {
  variables {
    bucket_prefix    = "test-bucket-prefix"
    cloud_account_id = run.setup_gcp_project.cloud_account_id
    name             = "test-name-update"
    region           = "us-central1"
    storage_class    = "COLDLINE"

    bucket_labels = merge(var.labels, {
      update = "true"
    })
  }

  # polaris_gcp_archival_location.archival_location.
  assert {
    condition     = polaris_gcp_archival_location.archival_location.bucket_labels == var.bucket_labels
    error_message = "The bucket labels should match the specified bucket labels."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.name == var.name
    error_message = "The name field should match the specified name."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.storage_class == var.storage_class
    error_message = "The storage class field should match the specified storage class."
  }
  assert {
    condition     = length(polaris_gcp_archival_location.archival_location.customer_managed_key) == 0
    error_message = "The customer managed keys field should be empty."
  }
}
