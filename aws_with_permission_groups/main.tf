terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.11"
    }
  }
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

provider "polaris" {}

resource "polaris_aws_account" "default" {
  profile = var.profile

  cloud_native_protection {
    permission_groups = [
      "BASIC"
    ]

    regions = [
      "us-east-2",
    ]
  }

  exocompute {
    permission_groups = [
      "BASIC",
      "RSC_MANAGED_CLUSTER"
    ]

    regions = [
      "us-east-2",
    ]
  }
}
