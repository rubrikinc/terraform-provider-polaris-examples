# AWS Cloud Cluster Basic Example

The configuration in this directory demonstrates how to create a basic RSC AWS Cloud Cluster (CCES). The configuration performs the following steps:

1. Onboard the AWS account to RSC with the `SERVERS_AND_APPS` feature.
2. Create an S3 bucket for the cloud cluster storage.
3. Create IAM roles and instance profile for the cluster nodes.
4. Create security groups for the cluster.
5. Deploy the AWS cloud cluster in the specified VPC and subnet.

## Prerequisites

- An AWS account with appropriate permissions
- A VPC with at least one subnet
- RSC account credentials configured

## Usage

To run this example, execute the following:

```bash
$ terraform init
$ terraform plan -var="vpc_id=vpc-xxxxx" -var="subnet_id=subnet-xxxxx"
$ terraform apply -var="vpc_id=vpc-xxxxx" -var="subnet_id=subnet-xxxxx"
```

> [!WARNING]
> This example creates resources which can incur significant costs. The cloud cluster deployment takes 30-60 minutes to complete. Run `terraform destroy` when you don't need these resources.

## What Gets Created

This example creates the following resources:

- **RSC Cloud Account**: AWS account onboarded to RSC
- **S3 Bucket**: Storage bucket for the cloud cluster (auto-generated name)
- **IAM Role & Instance Profile**: Permissions for cluster nodes
- **Security Group**: Network access controls for the cluster
- **Cloud Cluster**: The actual Rubrik cloud cluster with 3 nodes

## Customization

You can customize the deployment by modifying the variables in `main.tf`:

- `region`: AWS region for deployment (default: us-west-2)
- `tags`: Tags to apply to all resources
- Cluster configuration (num_nodes, instance_type, etc.)

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
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID where the cluster will be deployed | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the cluster will be deployed | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the cloud cluster | `string` | `"us-west-2"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources created which supports tags. | `map(string)` | <pre>{<br/>  "example": "basic",<br/>  "module": "aws_cloud_cluster",<br/>  "repository": "terraform-provider-polaris-examples"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_cluster_id"></a> [cloud\_cluster\_id](#output\_cloud\_cluster\_id) | The ID of the cloud cluster |
| <a name="output_cloud_cluster_name"></a> [cloud\_cluster\_name](#output\_cloud\_cluster\_name) | The name of the cloud cluster |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | The name of the IAM instance profile |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | The name of the S3 bucket |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
<!-- END_TF_DOCS -->

