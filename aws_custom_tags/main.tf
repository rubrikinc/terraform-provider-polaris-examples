# Example showing how to create RSC custom tags for AWS cloud resources.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=v1.1.0-beta.9"
    }
  }
}

provider "polaris" {}

resource "polaris_aws_custom_tags" "tags" {
  custom_tags = {
    "app"    = "RSC"
    "vendor" = "Rubrik"
  }
}
