terraform {
  required_providers {
    polaris = {
      source  = "rubrikinc/polaris"
      version = ">=0.7.0"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

variable "role_arn" {
  type        = string
  description = "Role ARN for the cross account role."
}

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
locals {
  accounts = csvdecode(file("accounts.csv"))
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the AWS accounts from the accounts.csv file to RSC. The provider will
# assume the role for each account and create a CloudFormation stack granting
# RSC access to the account.
resource "polaris_aws_account" "accounts" {
  for_each = {
    for account in local.accounts : account.role_arn => account
  }

  assume_role = each.key

  cloud_native_protection {
    regions = split(",", each.value.regions)
  }
}
