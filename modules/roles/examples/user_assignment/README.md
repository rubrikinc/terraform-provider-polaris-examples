# User Assignment Example

This example creates a custom role and assigns it to a user looked up via the `polaris_user` data
source.

## What This Example Creates

- A custom role named "Viewer Role" with a `VIEW_ROLE` permission
- A role assignment linking the custom role to the specified user

## Usage

1. Initialize the Terraform working directory:

   ```shell
   terraform init
   ```

2. Review the planned changes:

   ```shell
   terraform plan -var="user_email=user@example.com"
   ```

3. Apply the configuration:

   ```shell
   terraform apply -var="user_email=user@example.com"
   ```
