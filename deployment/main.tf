# Example showing how to access deployment specific information.
#
# The RSC service account is read from the
# RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

provider "polaris" {}

data "polaris_deployment" "deployment" {}

output "deployment_ip_addresses" {
  value = data.polaris_deployment.deployment.ip_addresses
}

output "deployment_version" {
  value = data.polaris_deployment.deployment.version
}
