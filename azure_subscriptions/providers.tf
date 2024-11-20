terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~>2.48.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.99.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.10.0-beta.7"
    }
  }
}


provider "azuread" {}

provider "azurerm" {
  features {}
}

provider "polaris" {}
