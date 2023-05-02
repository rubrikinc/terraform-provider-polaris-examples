# Point Terraform to the RSC provider.
terraform {
  required_providers {
    polaris = {
      source = "rubrikinc/polaris"
    }
  }
}

variable "polaris_credentials" {
  type        = string
  description = "Path to the RSC service account file."
}

# The accounts.csv file should contain all AWS accounts to add to RSC, using the
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
locals {
  accounts = csvdecode(file("accounts.csv"))
}

# Point the provider to the RSC service account to use.
provider "polaris" {
  credentials = var.polaris_credentials
}

# Add the AWS accounts from the accounts.csv file to RSC. Access keys and secret
# keys for profiles are read from ~/.aws/credentials. The default region for the
# profiles are read from ~/.aws/config. RSC will authenticate to AWS using an
# IAM role setup in a CloudFormation stack.
resource "polaris_aws_account" "accounts" {
  for_each = {
    for account in local.accounts : account.profile => account
  }

  profile = each.key

  cloud_native_protection {
    regions = split(",", each.value.regions)
  }
}
