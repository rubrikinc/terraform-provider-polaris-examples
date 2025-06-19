# Example showing how to access deployment specific information.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
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
