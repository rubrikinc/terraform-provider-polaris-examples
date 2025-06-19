terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "~>2.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.50.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.5.0"
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

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

provider "polaris" {}
