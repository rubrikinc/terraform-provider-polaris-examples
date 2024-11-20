# Onboarding multiple Azure subscriptions to RSC
If a large number of subscriptions are going to be onboarded to RSC at once it
might make sense to store the subscriptions information in a CSV,
_Comma-seperated Values_, file. Using a CSV file reduces the overall amount of
Terraform configuration needed to be written. An additional benefit is that
after the subscriptions have been onboarded they can be managed through the CSV
file. E.g. Removing a subscription from the CSV file followed by running
`terraform apply` will remove the subscription from RSC and changing the regions
for a subscription followed by running `terraform apply` will update the regions
in RSC.

The `main.tf` file, along with the two modules, and the `subscriptions.csv` file
gives an example of how this can be done. `main.tf` expects the
`subscriptions.csv` file to be in the following format:
```
# subscription_id,features,regions,resource_group_name,resource_group_region
# "<subscription-id-1>","<feature-1>,...,<feature-N>","<region-1>,...,<region-N>","<resource-group-name>","<resource-group-region>"
# "<subscription-id-2>","<feature-1>,...,<feature-N>","<region-1>,...,<region-N>","<resource-group-name>","<resource-group-region>"
```
E.g:
```
# subscription_id,features,regions,resource_group_name,resource_group_region
# "9fd78c2f-d502-4c56-8187-87526083bfa2","CLOUD_NATIVE_PROTECTION","eastus2","rsc-rg","eastus2"
# "76a49db1-f241-4936-838f-dd39dbd429d1","CLOUD_NATIVE_PROTECTION,EXOCOMPUTE","eastus2,westus2","rsc-rg","eastus2"
```
Note that the header, the first line of the CSV file, must be included in the
CSV file.
