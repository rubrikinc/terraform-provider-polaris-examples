terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }
}
