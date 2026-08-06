terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.7.0"
    }
  }

  required_version = ">=1.9.0"
}
