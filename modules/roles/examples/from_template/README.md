# From Template Example

This example creates a custom role based on a role template using the `polaris_role_template` data
source with dynamic blocks.

> **Note:** This example does not use the `modules/roles` module directly. It demonstrates the
> pattern of creating a custom role from a role template.

## What This Example Creates

- A custom role with permissions inherited from the specified role template (defaults to
  "Compliance Auditor")

## Usage

1. Initialize the Terraform working directory:

   ```shell
   terraform init
   ```

2. Review the planned changes:

   ```shell
   terraform plan
   ```

3. Apply the configuration:

   ```shell
   terraform apply
   ```

4. To use a different template:

   ```shell
   terraform apply -var="template_name=My Template"
   ```
