# AWS Cloud Cluster with Existing Resources Example

The configuration in this directory demonstrates how to create an RSC AWS Cloud Cluster (CCES) using existing AWS resources. This is useful when you have pre-existing infrastructure that you want to reuse, such as:

- An existing S3 bucket configured with specific encryption or lifecycle policies
- Pre-configured IAM roles and instance profiles with custom permissions
- Existing security groups with specific network access rules

## Prerequisites

Before running this example, you must have:

- An AWS account with appropriate permissions
- A VPC with at least one subnet
- An existing S3 bucket (configured for Rubrik cloud cluster use)
- An existing IAM instance profile with appropriate permissions
- Existing security group(s) with appropriate ingress/egress rules
- RSC account credentials configured

## Required IAM Permissions

The existing IAM instance profile must have permissions to:
- Read/write to the specified S3 bucket
- Access KMS keys (if using encrypted S3 bucket)
- EC2 instance permissions as required by Rubrik

## Required Security Group Rules

The existing security groups must allow:
- Ingress: Cluster node communication and management access
- Egress: Internet access for RSC communication and data transfer

## Usage

To run this example, execute the following:

```bash
$ terraform init
$ terraform plan \
  -var="vpc_id=vpc-xxxxx" \
  -var="subnet_id=subnet-xxxxx" \
  -var="existing_bucket_name=my-rubrik-bucket" \
  -var="existing_instance_profile_name=my-instance-profile" \
  -var='existing_security_group_ids=["sg-xxxxx","sg-yyyyy"]'
$ terraform apply \
  -var="vpc_id=vpc-xxxxx" \
  -var="subnet_id=subnet-xxxxx" \
  -var="existing_bucket_name=my-rubrik-bucket" \
  -var="existing_instance_profile_name=my-instance-profile" \
  -var='existing_security_group_ids=["sg-xxxxx","sg-yyyyy"]'
```

> [!WARNING]
> This example creates a cloud cluster which can incur significant costs. The deployment takes 30-60 minutes to complete. Run `terraform destroy` when you don't need these resources.

> [!IMPORTANT]
> Ensure your existing resources meet Rubrik's requirements before deployment. Incorrect configuration may cause deployment failures.

## What Gets Created

This example creates the following resources:

- **RSC Cloud Account**: AWS account onboarded to RSC
- **Cloud Cluster**: The Rubrik cloud cluster with 5 nodes (using existing infrastructure)

This example **does not** create:
- S3 bucket (uses existing)
- IAM roles/instance profile (uses existing)
- Security groups (uses existing)

## Benefits of Using Existing Resources

1. **Compliance**: Use pre-approved, compliant infrastructure
2. **Cost Control**: Leverage existing resources and avoid duplication
3. **Integration**: Integrate with existing monitoring, logging, and security tools
4. **Flexibility**: Maintain control over infrastructure configuration

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.4.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >= 1.1.7 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_cloud_cluster"></a> [aws\_cloud\_cluster](#module\_aws\_cloud\_cluster) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_existing_bucket_name"></a> [existing\_bucket\_name](#input\_existing\_bucket\_name) | Existing S3 bucket name to use for the cluster | `string` | n/a | yes |
| <a name="input_existing_instance_profile_name"></a> [existing\_instance\_profile\_name](#input\_existing\_instance\_profile\_name) | Existing IAM instance profile name to use for the cluster | `string` | n/a | yes |
| <a name="input_existing_security_group_ids"></a> [existing\_security\_group\_ids](#input\_existing\_security\_group\_ids) | Existing security group IDs to use for the cluster | `list(string)` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID where the cluster will be deployed | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the cluster will be deployed | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the cloud cluster | `string` | `"us-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created which supports tags. | `map(string)` | <pre>{<br/>  "example": "with_existing_resources",<br/>  "module": "aws_cloud_cluster",<br/>  "repository": "terraform-provider-polaris-examples"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_cluster_id"></a> [cloud\_cluster\_id](#output\_cloud\_cluster\_id) | The ID of the cloud cluster |
| <a name="output_cloud_cluster_name"></a> [cloud\_cluster\_name](#output\_cloud\_cluster\_name) | The name of the cloud cluster |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | The name of the IAM instance profile |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | The name of the S3 bucket |
<!-- END_TF_DOCS -->

