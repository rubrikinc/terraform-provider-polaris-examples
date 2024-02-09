terraform {
  required_version = ">=1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.26.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.25.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.15"
    }
  }
}

data "aws_region" "current" {}
