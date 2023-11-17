terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.6"
    }
  }
}

variable "profile" {
  type        = string
  description = "AWS profile."
}

variable "host_account_id" {
  type        = string
  description = "Shared exocompute host RSC account id."
}

provider "polaris" {}

resource "polaris_aws_account" "default" {
  profile = var.profile

  cloud_native_protection {
    regions = [
      "us-east-2",
    ]
  }

  exocompute {
    regions = [
      "us-east-2",
    ]
  }
}

resource "polaris_aws_exocompute" "default" {
  account_id      = polaris_aws_account.default.id
  host_account_id = var.host_account_id
}
