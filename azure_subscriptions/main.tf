# Example showing how to onboard multiple Azure subscriptions to RSC using a CSV
# file.
#
# The subscriptions.csv file should contain all Azure subscriptions to onboard
# to RSC, using the following format:
#
# subscription_id,features,regions,resource_group_name,resource_group_region
# "<subscription-id-1>","<feature-1>,...,<feature-N>","<region-1>,...,<region-N>","<resource-group-name>","<resource-group-region>"
# "<subscription-id-2>","<feature-1>,...,<feature-N>","<region-1>,...,<region-N>","<resource-group-name>","<resource-group-region>"
#
# E.g:
#
# subscription_id,features,regions,resource_group_name,resource_group_region
# "9fd78c2f-d502-4c56-8187-87526083bfa2","CLOUD_NATIVE_PROTECTION","eastus2","rsc-rg","eastus2"
# "76a49db1-f241-4936-838f-dd39dbd429d1","CLOUD_NATIVE_PROTECTION,EXOCOMPUTE","eastus2,westus2","rsc-rg","eastus2"
#
# The header, the first line of the CSV file, must also be included in the CSV
# file.
#
# After the subscriptions have been onboarded they can be managed through the
# CSV file. Removing a subscription from the CSV file followed by running
# terraform apply will remove the subscription from RSC. Changing the regions
# for a subscription followed by running terraform apply will update the regions
# in RSC.

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
