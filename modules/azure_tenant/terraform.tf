terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.48.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.9.1"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }

  required_version = ">=1.9.0"
}
