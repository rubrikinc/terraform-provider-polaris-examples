variable "gcp_project_id" {
  description = "GCP project ID."
  type        = string
}

variables {
  labels = {
    test       = "customer_managed_keys_specific_region"
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
          "ENCRYPTION",
        ]
      }
    }
  }
}

run "setup_crypto_key" {
  module {
    source = "./modules/crypto_key"
  }

  variables {
    key_name        = "terraform-module-test-key3"
    key_ring_name   = "terraform-module-test-key-ring3"
    region          = "us-central1"
  }

  # Outputs.
  assert {
    condition     = output.key_id != ""
    error_message = "The key id output should not be empty."
  }
  assert {
    condition     = output.key_name == var.key_name
    error_message = "The key name output should match the specified key name."
  }
  assert {
    condition     = output.key_ring_name == var.key_ring_name
    error_message = "The key ring name output should match the specified key ring name."
  }
}

# Test creating an archival location with customer managed keys for a specific
# region.
run "archival_location" {
  variables {
    bucket_labels    = var.labels
    bucket_prefix    = "test-bucket-prefix"
    cloud_account_id = run.setup_gcp_project.cloud_account_id
    name             = "test-name"
    region           = "us-central1"

    customer_managed_keys = [{
      name      = "terraform-module-test-key3"
      ring_name = "terraform-module-test-key-ring3"
      region    = "us-central1"
    }]
  }

  # data.polaris_gcp_project.project.
  assert {
    condition     = data.polaris_gcp_project.project.id == run.setup_gcp_project.cloud_account_id
    error_message = "The ID field should match the GCP Project cloud account ID."
  }
  assert {
    condition     = data.polaris_gcp_project.project.project_id == var.gcp_project_id
    error_message = "The project ID field should match the specified project ID."
  }

  # data.google_project.project.
  assert {
    condition     = data.google_project.project.project_id == var.gcp_project_id
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

  # data.google_kms_key_ring.key_ring.
  assert {
    condition     = toset(keys(data.google_kms_key_ring.key_ring)) == toset(["us-central1/terraform-module-test-key-ring3"])
    error_message = "The key ring should be keyed by region/ring_name."
  }
  assert {
    condition     = data.google_kms_key_ring.key_ring["us-central1/terraform-module-test-key-ring3"].name == "terraform-module-test-key-ring3"
    error_message = "The key ring name should match the specified name."
  }
  assert {
    condition     = data.google_kms_key_ring.key_ring["us-central1/terraform-module-test-key-ring3"].location == "us-central1"
    error_message = "The key ring location should match the specified region."
  }

  # data.google_kms_crypto_key.key.
  assert {
    condition     = toset(keys(data.google_kms_crypto_key.key)) == toset(["us-central1/terraform-module-test-key-ring3/terraform-module-test-key3"])
    error_message = "The crypto key should be keyed by region/ring_name/key_name."
  }
  assert {
    condition     = data.google_kms_crypto_key.key["us-central1/terraform-module-test-key-ring3/terraform-module-test-key3"].name == "terraform-module-test-key3"
    error_message = "The crypto key name should match the specified name."
  }

  # google_kms_crypto_key_iam_member.key.
  assert {
    condition     = length(google_kms_crypto_key_iam_member.key) == 1
    error_message = "The Google Storage service account should be added as an IAM member to the crypto key."
  }
  assert {
    condition     = google_kms_crypto_key_iam_member.key["us-central1/terraform-module-test-key-ring3/terraform-module-test-key3"].role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    error_message = "The Google Storage service account should have the cryptoKeyEncrypterDecrypter role for the crypto key."
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
    condition     = polaris_gcp_archival_location.archival_location.location_template == "SPECIFIC_REGION"
    error_message = "The location template should be SPECIFIC_REGION when region is specified."
  }
  assert {
    condition     = length(polaris_gcp_archival_location.archival_location.customer_managed_key) == 1
    error_message = "The customer managed keys field should contain 1 key."
  }
  assert {
    condition     = one(polaris_gcp_archival_location.archival_location.customer_managed_key[*].name) == "terraform-module-test-key3"
    error_message = "The customer managed key name should be terraform-module-test-key3."
  }
  assert {
    condition     = one(polaris_gcp_archival_location.archival_location.customer_managed_key[*].ring_name) == "terraform-module-test-key-ring3"
    error_message = "The customer managed key ring name should be terraform-module-test-key-ring3."
  }
  assert {
    condition     = one(polaris_gcp_archival_location.archival_location.customer_managed_key[*].region) == "us-central1"
    error_message = "The customer managed key region should be us-central1."
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
