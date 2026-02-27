# SSO Group Assignment Example

This example creates a custom role and assigns it to an SSO group looked up via the
`polaris_sso_group` data source.

## What This Example Creates

- A custom role named "SSO Viewer Role" with a `VIEW_ROLE` permission
- A role assignment linking the custom role to the specified SSO group

## Usage

1. Initialize the Terraform working directory:

   ```shell
   terraform init
   ```

2. Review the planned changes:

   ```shell
   terraform plan -var="sso_group_name=my-sso-group"
   ```

3. Apply the configuration:

   ```shell
   terraform apply -var="sso_group_name=my-sso-group"
   ```
