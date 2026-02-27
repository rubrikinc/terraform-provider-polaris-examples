# Basic Custom Role Example

This example creates a simple custom role with hardcoded permission strings.

## What This Example Creates

- A custom role named "Compliance Auditor Role" with two permissions:
  - `EXPORT_DATA_CLASS_GLOBAL` - Export data classification results
  - `VIEW_DATA_CLASS_GLOBAL` - View data classification results

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
