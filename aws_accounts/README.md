# Adding multiple AWS accounts to RSC
If a large number of accounts are going to be added to RSC at once it might make
sense to store the account information in a CSV, _Comma-seperated Values_, file.
Using a CSV file reduces the overall amount of Terraform configuration needed to
be written. An additional benefit is that after the accounts have been added
they can be managed through the CSV file. E.g. Removing an account from the CSV
file followed by running `terraform apply` will remove the account from RSC and
changing the regions for an account followed by running `terraform apply` will
update the regions in RSC.

The `main.tf` and `accounts.csv` files gives an example of how this can be done.
`main.tf` expects the `accounts.csv` file to be in the following format:
```
profile,regions
"<profile-1>","<region-1>,<region-2>...<region-N>"
"<profile-2>","<region-1>,<region-2>...<region-N>"
```
E.g:
```
profile,regions
"admin","us-east-2,us-west-2"
"devops","us-west-2,eu-north-1"
```
Note that the header, the first line of the CSV file, must be included in the
CSV file.
