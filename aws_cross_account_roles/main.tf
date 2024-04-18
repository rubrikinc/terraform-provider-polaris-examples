# Example showing how to onboard multiple AWS accounts, identified by role ARNs,
# to RSC using a CSV file. The provider will assume each role and create a
# CloudFormation stack granting RSC access to the account.
#
# The AWS default profile and the profile's default region are read from the
# standard ~/.aws/credentials and ~/.aws/config files. The RSC service account
# is read from the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment
# variable.
#
# The accounts.csv file should contain all AWS accounts to add to RSC, using the
# following format:
#
# role_arn,regions
# "<role-arn-1>","<region-1>,<region-2>...<region-N>"
# "<role-arn-2>","<region-1>,<region-2>...<region-N>"
#
# E.g:
#
# role_arn,regions
# "arn:aws:iam::123456789012:role/AdminRole","us-east-2"
# "arn:aws:iam::567890123456:role/DevopsRole","us-west-2,eu-north-1"
#
# The header, the first line of the CSV file, must also be included in the CSV
# file.
#
# After the accounts have been added they can be managed through the CSV file.
# Removing an account from the CSV file followed by running terraform apply will
# remove the account from RSC. Changing the regions for an account followed by
# running terraform apply will update the regions in RSC.

terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

locals {
  accounts = csvdecode(file("accounts.csv"))
}

provider "polaris" {}

resource "polaris_aws_account" "accounts" {
  for_each = {
    for account in local.accounts : account.role_arn => account
  }

  assume_role = each.key

  cloud_native_protection {
    regions = split(",", each.value.regions)
  }
}
