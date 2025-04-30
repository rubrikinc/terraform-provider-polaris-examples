terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.50.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.12.0"
    }
  }
}

provider "aws" {}

provider "polaris" {}
