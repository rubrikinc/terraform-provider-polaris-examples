terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=1.4.0-beta.5"
    }
  }

  # Terraform 1.11.0 is required for the tests.
  required_version = ">=1.11.0"
}
