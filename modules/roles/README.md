# Roles Module

This module manages RSC custom roles and role assignments. It creates a custom role with the
specified permissions and optionally assigns it to users and/or SSO groups.

## Usage

### Basic Custom Role

```hcl
module "compliance_auditor" {
  source = "path/to/modules/roles"

  name        = "Compliance Auditor Role"
  description = "Basic custom role for compliance auditing"

  permissions = [
    {
      operation = "EXPORT_DATA_CLASS_GLOBAL"
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        }
      ]
    },
    {
      operation = "VIEW_DATA_CLASS_GLOBAL"
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        }
      ]
    },
  ]
}
```

### Custom Role with User Assignment

```hcl
data "polaris_user" "user" {
  email = "user@example.com"
}

module "viewer_role" {
  source = "path/to/modules/roles"

  name        = "Viewer Role"
  description = "Read-only role assigned to a user"

  permissions = [
    {
      operation = "VIEW_ROLE"
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        }
      ]
    },
  ]

  user_ids = [data.polaris_user.user.id]
}
```

### Custom Role with SSO Group Assignment

```hcl
data "polaris_sso_group" "group" {
  name = "my-sso-group"
}

module "sso_viewer_role" {
  source = "path/to/modules/roles"

  name        = "SSO Viewer Role"
  description = "Read-only role assigned to an SSO group"

  permissions = [
    {
      operation = "VIEW_ROLE"
      hierarchy = [
        {
          snappable_type = "AllSubHierarchyType"
          object_ids     = ["GlobalResource"]
        }
      ]
    },
  ]

  sso_group_ids = [data.polaris_sso_group.group.id]
}
```

## Examples

- [Basic](examples/basic) - Simple custom role with hardcoded permission strings.
- [Data Sources](examples/data_sources) - Custom role using `polaris_operations` and
  `polaris_workloads` data sources.
- [Azure Admin](examples/azure_admin) - Multi-permission Azure admin role with multiple hierarchy
  scopes.
- [User Assignment](examples/user_assignment) - Custom role assigned to a user via data source
  lookup.
- [SSO Group Assignment](examples/sso_group_assignment) - Custom role assigned to an SSO group.
- [From Template](examples/from_template) - Custom role from a `polaris_role_template` data source.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >=1.11.0 |
| polaris | >=9.0.0 |

## Providers

| Name | Version |
|------|---------|
| polaris | >=9.0.0 |

## Resources

| Name | Type |
|------|------|
| [polaris_custom_role.role](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/custom_role) | resource |
| [polaris_role_assignment.user](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/role_assignment) | resource |
| [polaris_role_assignment.sso_group](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the custom role. | `string` | n/a | yes |
| description | Description of the custom role. | `string` | `null` | no |
| permissions | List of permissions for the custom role. Each permission specifies an operation and a list of hierarchies defining the scope. | `list(object({...}))` | n/a | yes |
| user\_ids | Set of user IDs to assign the custom role to. | `set(string)` | `[]` | no |
| sso\_group\_ids | Set of SSO group IDs to assign the custom role to. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| role\_id | The custom role ID. |
| role\_name | The custom role name. |
| user\_assignment\_ids | Map of user IDs to assignment IDs. |
| sso\_group\_assignment\_ids | Map of SSO group IDs to assignment IDs. |
<!-- END_TF_DOCS -->
