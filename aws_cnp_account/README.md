# AWS CNP Account

The configuration in this directory onboards an AWS account to RSC using the IAM roles workflow. Sometimes this workflow
is also referred to as the non-CFT (CloudFormation Template) workflow.

## Usage

```terraform
module "aws_cnp_account" {
  source = "../.."

  account_name = "My Account"
  account_id   = "123456789012"

  features = {
    CLOUD_NATIVE_ARCHIVAL = {
      permission_groups = [
        "BASIC"
      ]
    },
    CLOUD_NATIVE_DYNAMODB_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    CLOUD_NATIVE_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    CLOUD_NATIVE_S3_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
    EXOCOMPUTE = {
      permission_groups = [
        "BASIC",
        "RSC_MANAGED_CLUSTER"
      ]
    },
    RDS_PROTECTION = {
      permission_groups = [
        "BASIC"
      ]
    },
  }

  regions = [
    "us-east-2",
    "us-west-2",
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=5.70.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.2.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.15.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | 1.2.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.customer_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.customer_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachments_exclusive.customer_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachments_exclusive) | resource |
| [aws_iam_role_policy_attachments_exclusive.customer_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachments_exclusive) | resource |
| [polaris_aws_cnp_account.account](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_cnp_account) | resource |
| [polaris_aws_cnp_account_attachments.attachments](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_cnp_account_attachments) | resource |
| [time_sleep.wait_for_rsc](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [polaris_aws_cnp_artifacts.artifacts](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/aws_cnp_artifacts) | data source |
| [polaris_aws_cnp_permissions.permissions](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/data-sources/aws_cnp_permissions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | AWS account ID. | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | AWS account name. | `string` | n/a | yes |
| <a name="input_cloud_type"></a> [cloud\_type](#input\_cloud\_type) | AWS cloud type. Possible values are: STANDARD, GOV. Defaults to STANDARD. | `string` | `null` | no |
| <a name="input_ec2_recovery_role_path"></a> [ec2\_recovery\_role\_path](#input\_ec2\_recovery\_role\_path) | AWS EC2 recovery role path. | `string` | `null` | no |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | AWS external ID. If empty, RSC will automatically generate an external ID. | `string` | `null` | no |
| <a name="input_features"></a> [features](#input\_features) | RSC features with permission groups. Possible features are: CLOUD\_NATIVE\_ARCHIVAL, CLOUD\_NATIVE\_DYNAMODB\_PROTECTION, CLOUD\_NATIVE\_PROTECTION, CLOUD\_NATIVE\_S3\_PROTECTION, EXOCOMPUTE, RDS\_PROTECTION and SERVERS\_AND\_APPS. | <pre>map(object({<br/>    permission_groups = set(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_regions"></a> [regions](#input\_regions) | AWS regions to onboard. | `set(string)` | n/a | yes |
| <a name="input_role_path"></a> [role\_path](#input\_role\_path) | AWS role path. Defaults to '/'. | `string` | `"/"` | no |
| <a name="input_role_type"></a> [role\_type](#input\_role\_type) | How the AWS policies should be attached to the IAM roles created for RSC. Possible values: `managed`, `inline` and `legacy`. `legacy` should only be used for backwards compatibility with previously onboarded AWS accounts. | `string` | `"managed"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created. | `map(string)` | <pre>{<br/>  "Environment": "test",<br/>  "Example": "aws_cnp_account",<br/>  "Module": "github.com/rubrikinc/terraform-provider-polaris-examples"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_account_id"></a> [cloud\_account\_id](#output\_cloud\_account\_id) | RSC cloud account ID for the AWS account. |
<!-- END_TF_DOCS -->
