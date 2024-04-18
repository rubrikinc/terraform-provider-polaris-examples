# Example showing how to onboard multiple AWS accounts to RSC using a CSV file.
# The RSC provider will create a CloudFormation stack in each account granting
# RSC access.
#
# Each AWS profile and the profile's default region are read from the standard
# ~/.aws/credentials and ~/.aws/config files. The RSC service account is read
# from the RUBRIK_POLARIS_SERVICEACCOUNT_CREDENTIALS environment variable.
#
# The accounts.csv file should contain all AWS accounts to onboard to RSC, using
# the following format:
#
# profile,regions
# "<profile-1>","<region-1>,<region-2>...<region-N>"
# "<profile-2>","<region-1>,<region-2>...<region-N>"
#
# E.g:
#
# profile,regions
# "admin","us-east-2,us-west-2"
# "devops","us-west-2,eu-north-1"
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
    for account in local.accounts : account.profile => account
  }

  profile = each.key

  cloud_native_protection {
    regions = split(",", each.value.regions)
  }
}
