# Example showing how to access account specific information.
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
