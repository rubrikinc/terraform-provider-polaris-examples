terraform {
  required_providers {
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=9.0.0"
    }
  }

  # Terraform 1.11.0 is required for the tests.
  required_version = ">=1.11.0"
}
