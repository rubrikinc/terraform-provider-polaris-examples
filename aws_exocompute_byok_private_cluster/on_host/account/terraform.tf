terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.50.0"
    }
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}
