# Azure Admin Role Example

This example creates a multi-permission Azure admin role with multiple hierarchy scopes.

## What This Example Creates

- A custom role named "Azure Admin Role" with permissions for:
  - `MANAGE_PROTECTION_AZURE` - Manage protection for Azure VMs and Managed Disks
  - `VIEW_INVENTORY_AZURE` - View Azure inventory
  - `EXPORT_SNAPSHOTS_AZURE` - Export Azure VM snapshots

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
