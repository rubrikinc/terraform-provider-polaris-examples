terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=7.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }

  # Terraform 1.11.0 is required for the tests.
  required_version = ">=1.11.0"
}

# These locals are used in the tests.
locals {
  uuid_null  = "00000000-0000-0000-0000-000000000000"
  uuid_regex = "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}
