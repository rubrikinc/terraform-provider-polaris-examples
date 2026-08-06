terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">=3.2.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.9.1"
    }
  }

  required_version = ">=1.9.0"
}
