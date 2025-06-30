terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.50.0"
    }
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
}

provider "aws" {}

provider "polaris" {}
