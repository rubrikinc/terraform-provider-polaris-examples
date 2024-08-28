terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    polaris = {
      source = "terraform.rubrik.com/rubrikinc/polaris"
    }
  }
}

data "aws_region" "current" {}
