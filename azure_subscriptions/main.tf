# Example showing how to onboard an Azure subscription with a specific feature
# and Terraform permissions management.

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

locals {
  subscriptions = csvdecode(file("subscriptions.csv"))
}

module "app" {
  source = "./app"
}

module "subscription" {
  source = "./subscription"

  for_each = {
    for subscription in local.subscriptions : subscription.subscription_id => subscription
  }

  features              = split(",", each.value.features)
  principal_id          = module.app.principal_id
  regions               = split(",", each.value.regions)
  resource_group_name   = each.value.resource_group_name
  resource_group_region = each.value.resource_group_region
  subscription_id       = each.key
  tenant_domain         = module.app.tenant_domain
}
