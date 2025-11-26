variable "gcp_project_id" {
  description = "GCP project ID."
  type        = string
}

variables {
  labels = {
    test       = "customer_managed_keys_source_region"
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

run "setup_crypto_key1" {
  module {
    source = "./modules/crypto_key"
  }

  variables {
    key_name        = "terraform-module-test-key1"
    key_ring_name   = "terraform-module-test-key-ring1"
    region          = "us-east1"
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

run "setup_crypto_key2" {
  module {
    source = "./modules/crypto_key"
  }

  variables {
    key_name        = "terraform-module-test-key2"
    key_ring_name   = "terraform-module-test-key-ring2"
    region          = "us-west1"
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

# Test archival location with multiple customer-managed encryption keys.
run "archival_location" {
  variables {
    bucket_labels    = var.labels
    bucket_prefix    = "test-bucket-prefix"
    cloud_account_id = run.setup_gcp_project.cloud_account_id
    name             = "test-name"

    customer_managed_keys = [
      {
        name      = "terraform-module-test-key1"
        ring_name = "terraform-module-test-key-ring1"
        region    = "us-east1"
      },
      {
        name      = "terraform-module-test-key2"
        ring_name = "terraform-module-test-key-ring2"
        region    = "us-west1"
      }
    ]
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

  # data.google_kms_key_ring.key_ring.
  assert {
    condition     = toset(keys(data.google_kms_key_ring.key_ring)) == toset(["us-east1/terraform-module-test-key-ring1", "us-west1/terraform-module-test-key-ring2"])
    error_message = "The key rings should be keyed by region/ring_name."
  }
  assert {
    condition     = data.google_kms_key_ring.key_ring["us-east1/terraform-module-test-key-ring1"].name == "terraform-module-test-key-ring1"
    error_message = "The first key ring name should match the specified name."
  }
  assert {
    condition     = data.google_kms_key_ring.key_ring["us-east1/terraform-module-test-key-ring1"].location == "us-east1"
    error_message = "The first key ring location should match the specified region."
  }
  assert {
    condition     = data.google_kms_key_ring.key_ring["us-west1/terraform-module-test-key-ring2"].name == "terraform-module-test-key-ring2"
    error_message = "The second key ring name should match the specified name."
  }
  assert {
    condition     = data.google_kms_key_ring.key_ring["us-west1/terraform-module-test-key-ring2"].location == "us-west1"
    error_message = "The second key ring location should match the specified region."
  }

  # data.google_kms_crypto_key.key.
  assert {
    condition     = toset(keys(data.google_kms_crypto_key.key)) == toset(["us-east1/terraform-module-test-key-ring1/terraform-module-test-key1", "us-west1/terraform-module-test-key-ring2/terraform-module-test-key2"])
    error_message = "The crypto keys should be keyed by region/ring_name/key_name."
  }
  assert {
    condition     = data.google_kms_crypto_key.key["us-east1/terraform-module-test-key-ring1/terraform-module-test-key1"].name == "terraform-module-test-key1"
    error_message = "The first crypto key name should match the specified name."
  }
  assert {
    condition     = data.google_kms_crypto_key.key["us-west1/terraform-module-test-key-ring2/terraform-module-test-key2"].name == "terraform-module-test-key2"
    error_message = "The second crypto key name should match the specified name."
  }

  # google_kms_crypto_key_iam_member.key.
  assert {
    condition     = length(google_kms_crypto_key_iam_member.key) == 2
    error_message = "The Google Storage service account should be added as an IAM member to both crypto keys."
  }
  assert {
    condition     = google_kms_crypto_key_iam_member.key["us-east1/terraform-module-test-key-ring1/terraform-module-test-key1"].role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    error_message = "The Google Storage service account should have the cryptoKeyEncrypterDecrypter role for the first crypto key."
  }
  assert {
    condition     = google_kms_crypto_key_iam_member.key["us-west1/terraform-module-test-key-ring2/terraform-module-test-key2"].role == "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    error_message = "The Google Storage service account should have the cryptoKeyEncrypterDecrypter role for the second crypto key."
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
    # TODO: Fix this.
    condition     = polaris_gcp_archival_location.archival_location.region == null || polaris_gcp_archival_location.archival_location.region == ""
    error_message = "The region field should be null for SOURCE_REGION archival locations."
  }
  assert {
    condition     = polaris_gcp_archival_location.archival_location.location_template == "SOURCE_REGION"
    error_message = "The location template should be SOURCE_REGION when region is not specified."
  }
  assert {
    condition     = length(polaris_gcp_archival_location.archival_location.customer_managed_key) == 2
    error_message = "The customer managed keys field should contain 2 keys."
  }
  assert {
    condition     = contains([for k in polaris_gcp_archival_location.archival_location.customer_managed_key : k.name], "terraform-module-test-key1")
    error_message = "The customer managed keys should include terraform-module-test-key1."
  }
  assert {
    condition     = contains([for k in polaris_gcp_archival_location.archival_location.customer_managed_key : k.name], "terraform-module-test-key2")
    error_message = "The customer managed keys should include terraform-module-test-key2."
  }
  assert {
    condition     = contains([for k in polaris_gcp_archival_location.archival_location.customer_managed_key : k.ring_name], "terraform-module-test-key-ring1")
    error_message = "The customer managed keys should include terraform-module-test-key-ring1."
  }
  assert {
    condition     = contains([for k in polaris_gcp_archival_location.archival_location.customer_managed_key : k.ring_name], "terraform-module-test-key-ring2")
    error_message = "The customer managed keys should include terraform-module-test-key-ring2."
  }
  assert {
    condition     = contains([for k in polaris_gcp_archival_location.archival_location.customer_managed_key : k.region], "us-east1")
    error_message = "The customer managed keys should include us-east1 region."
  }
  assert {
    condition     = contains([for k in polaris_gcp_archival_location.archival_location.customer_managed_key : k.region], "us-west1")
    error_message = "The customer managed keys should include us-west1 region."
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
