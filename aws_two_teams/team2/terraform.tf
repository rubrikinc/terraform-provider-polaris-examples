terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">=0.13.1"
    }
  }
}
