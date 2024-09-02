terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.26.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.10.0-beta.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.12.0"
    }
  }
}

provider "aws" {}

provider "polaris" {}
