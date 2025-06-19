terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>3.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.8.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

provider "polaris" {}
