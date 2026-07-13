terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.99.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.7.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }
}
