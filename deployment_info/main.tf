terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.11"
    }
  }
}

data "polaris_deployment" "default" {}

output "ip_addresses" {
  value = data.polaris_deployment.default.ip_addresses
}

output "version" {
  value = data.polaris_deployment.default.version
}
