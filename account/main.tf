# Example showing how to access account specific information with the
# polaris_account data source.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=1.0.0"
    }
  }
}

provider "polaris" {}

data "polaris_account" "account" {}

output "account_name" {
  value = data.polaris_account.account.name
}

output "account_fqdn" {
  value = data.polaris_account.account.fqdn
}

output "account_features" {
  value = data.polaris_account.account.features
}
