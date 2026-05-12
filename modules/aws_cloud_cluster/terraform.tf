terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.4.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">= 1.1.7"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }

  required_version = ">=1.13.0"
}
