# Data Sources Example

This example creates a custom role using the `polaris_operations` and `polaris_workloads` data sources
to dynamically build the permissions list.

## What This Example Creates

- A custom role named "AWS Viewer Role" with permissions derived from the `polaris_operations` data
  source, filtering for `VIEW` operations on `AWS` workloads.

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
