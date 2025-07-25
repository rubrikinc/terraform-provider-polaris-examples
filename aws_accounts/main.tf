# Example showing how to onboard multiple AWS account to RSC using a CSV file.
# The RSC provider will create a CloudFormation stack in each account granting
# RSC access to the AWS accounts.
#
# The accounts.csv file should contain all AWS accounts to onboard, using the
# following format:
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
      version = ">=1.0.0"
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
    permission_groups = [
      "BASIC",
    ]

    regions = split(",", each.value.regions)
  }
}
