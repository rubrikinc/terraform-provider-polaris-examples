# Adding multiple GCP projects to RSC
If a large number of projects are going to be added to RSC at once it might make
sense to store the project information in a CSV, _Comma-seperated Values_, file.
Using a CSV file reduces the overall amount of Terraform configuration needed to
be written. An additional benefit is that after the projects have been added
they can be managed through the CSV file. E.g. Removing a project from the CSV
file followed by running `terraform apply` will remove the project from RSC.

The `main.tf` and `projects.csv` files gives an example of how this can be done.
`main.tf` expects the `projects.csv` file to be in the following format:
```
project,credentials
"<project-1>","<service-account-1>"
"<project-2>","<service-account-2>"
"<project-N>","<service-account-N>"
```
E.g:
```
project,credentials
"my-proj","my-proj-service-account.json"
"another-proj","another-proj-service-account.json"
```
Note that the header, the first line of the CSV file, must be included in the
CSV file.
