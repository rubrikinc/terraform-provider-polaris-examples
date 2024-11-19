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
      version = "=0.10.0-beta.7"
    }
  }
}

provider "azuread" {}

provider "azurerm" {
  features {}
}

provider "polaris" {}
