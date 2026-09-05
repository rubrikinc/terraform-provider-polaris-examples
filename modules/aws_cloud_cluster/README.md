# AWS Cloud Cluster Module

This module manages an RSC AWS Cloud Cluster (Cloud Cluster Elastic Storage - CCES) deployment. The module handles the complete setup including AWS account onboarding to RSC, IAM role creation, S3 bucket provisioning, security group configuration, and cloud cluster deployment.

To create an AWS cloud cluster, the AWS account must be onboarded to RSC with the `SERVERS_AND_APPS` feature and the `CLOUD_CLUSTER_ES` permission group. This module automatically handles the onboarding process.

The module provides flexibility by allowing you to either:
- Automatically create all required AWS resources (S3 bucket, IAM roles, security groups)
- Use existing AWS resources by providing their identifiers

> [!NOTE]
> The module includes a 30-second wait time after account onboarding to ensure RSC is fully provisioned before creating the cloud cluster. This prevents potential errors from onboarding the cluster too quickly.

> [!NOTE]
> The module automatically generates an S3 bucket name in the format `{cluster_name}-rubrik-cluster.do.not.delete` if no bucket name is provided.

> [!IMPORTANT]
> Cloud cluster deployment can take 30-60 minutes to complete. Ensure your Terraform timeout settings accommodate this duration.

## Usage

### Basic Usage with Auto-Created Resources

This example creates all required AWS resources automatically:

```terraform
module "aws_cloud_cluster" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/aws_cloud_cluster"

  # Cloud Account Configuration
  cloud_account_name = "my-aws-account"
  region             = "us-west-2"

  # Cluster Configuration
  cluster_name   = "my-cloud-cluster"
  admin_email    = "admin@example.com"
  admin_password = "RubrikGoForward!"

  # Network Configuration
  vpc_id    = "vpc-12345678"
  subnet_id = "subnet-12345678"

  # Optional: Use prefix lists for security group rules
  ingress_allowed_prefix_list_ids = ["pl-12345678"]
  egress_allowed_prefix_list_ids  = ["pl-87654321"]

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Using Existing AWS Resources

This example uses existing S3 bucket, IAM instance profile, and security groups:

```terraform
module "aws_cloud_cluster" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/aws_cloud_cluster"

  # Cloud Account Configuration
  cloud_account_name = "my-aws-account"
  region             = "us-west-2"

  # Cluster Configuration
  cluster_name   = "my-cloud-cluster"
  admin_email    = "admin@example.com"
  admin_password = "RubrikGoForward!"

  # Network Configuration
  vpc_id    = "vpc-12345678"
  subnet_id = "subnet-12345678"

  # Use Existing Resources
  bucket_name           = "existing-rubrik-bucket"
  instance_profile_name = "existing-instance-profile"
  security_group_ids    = ["sg-12345678", "sg-87654321"]
}
```

### Advanced Configuration with Custom Settings

```terraform
module "aws_cloud_cluster" {
  source = "github.com/rubrikinc/terraform-provider-polaris-examples//modules/aws_cloud_cluster"

  # Cloud Account Configuration
  cloud_account_name = "my-aws-account"
  region             = "us-east-1"

  # Cluster Configuration
  cluster_name        = "production-cluster"
  admin_email         = "admin@example.com"
  admin_password      = "RubrikGoForward!"
  num_nodes           = 5
  enable_immutability = true

  # VM Configuration
  cdm_version   = "9.4.0-p2-30507"
  instance_type = "M6I_4XLARGE"
  vm_type       = "EXTRA_DENSE"

  # Network Configuration
  vpc_id                      = "vpc-12345678"
  subnet_id                   = "subnet-12345678"
  ingress_allowed_cidr_blocks = ["10.0.0.0/8"]
  egress_allowed_cidr_blocks  = ["0.0.0.0/0"]

  # DNS and NTP Configuration
  dns_name_servers   = ["10.0.0.2", "10.0.0.3"]
  dns_search_domains = ["example.com", "internal.example.com"]
  ntp_servers        = ["time.example.com"]

  # KMS Encryption (optional)
  kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Security Group Configuration

The module supports two methods for configuring security group ingress/egress rules:

1. **Prefix Lists** (Recommended for AWS-managed services):
   - Use `ingress_allowed_prefix_list_ids` and `egress_allowed_prefix_list_ids`
   - Ideal for S3, DynamoDB, and other AWS service endpoints

2. **CIDR Blocks** (For custom IP ranges):
   - Use `ingress_allowed_cidr_blocks` and `egress_allowed_cidr_blocks`
   - Suitable for on-premises networks or specific IP ranges

> [!WARNING]
> You cannot use both prefix lists and CIDR blocks for the same direction (ingress or egress). The module includes validation to prevent this.

## Resource Creation Logic

The module conditionally creates resources based on provided variables:

| Resource | Created When | Used When |
|----------|-------------|-----------|
| S3 Bucket | `bucket_name` is `null` | `bucket_name` is provided |
| IAM Role & Instance Profile | `instance_profile_name` is `null` | `instance_profile_name` is provided |
| Security Group | `security_group_ids` is `null` | `security_group_ids` is provided |

## Examples

- [Basic Example](examples/basic) - Deploy a cloud cluster with auto-created resources
- [With Existing Resources Example](examples/with_existing_resources) - Deploy using existing S3, IAM, and security groups

## Testing

The module includes comprehensive tests:

- **Validation Tests** (`tests/validation.tftest.hcl`) - Validates input variable constraints
- **Basic Tests** (`tests/basic.tftest.hcl`) - Tests module configuration and resource creation logic

To run the tests:

```bash
terraform test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.4.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >= 1.1.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.4.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >= 1.1.7 |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account"></a> [account](#module\_account) | ./modules/aws_cnp_account | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_s3"></a> [s3](#module\_s3) | ./modules/s3 | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | ./modules/security-group | n/a |

## Resources

| Name | Type |
|------|------|
| [polaris_aws_cloud_cluster.example](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_cloud_cluster) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Admin email for the cluster | `string` | n/a | yes |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Admin password for the cluster | `string` | n/a | yes |
| <a name="input_cloud_account_name"></a> [cloud\_account\_name](#input\_cloud\_account\_name) | AWS account name shown in RSC | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the cloud cluster | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID where the cluster will be deployed | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the cluster will be deployed | `string` | n/a | yes |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | S3 bucket name (optional - will be created if not provided) | `string` | `null` | no |
| <a name="input_cdm_version"></a> [cdm\_version](#input\_cdm\_version) | CDM version | `string` | `"9.4.0-p2-30507"` | no |
| <a name="input_dns_name_servers"></a> [dns\_name\_servers](#input\_dns\_name\_servers) | DNS name servers | `list(string)` | <pre>[<br/>  "8.8.8.8",<br/>  "8.8.4.4"<br/>]</pre> | no |
| <a name="input_dns_search_domains"></a> [dns\_search\_domains](#input\_dns\_search\_domains) | DNS search domains | `list(string)` | <pre>[<br/>  "example.com"<br/>]</pre> | no |
| <a name="input_egress_allowed_cidr_blocks"></a> [egress\_allowed\_cidr\_blocks](#input\_egress\_allowed\_cidr\_blocks) | CIDR blocks allowed for egress security group access (use either this OR egress\_allowed\_prefix\_list\_ids, not both) | `list(string)` | `[]` | no |
| <a name="input_egress_allowed_prefix_list_ids"></a> [egress\_allowed\_prefix\_list\_ids](#input\_egress\_allowed\_prefix\_list\_ids) | Prefix list IDs allowed for egress security group access (use either this OR egress\_allowed\_cidr\_blocks, not both) | `list(string)` | `[]` | no |
| <a name="input_enable_immutability"></a> [enable\_immutability](#input\_enable\_immutability) | Enable S3 bucket immutability | `bool` | `true` | no |
| <a name="input_ingress_allowed_cidr_blocks"></a> [ingress\_allowed\_cidr\_blocks](#input\_ingress\_allowed\_cidr\_blocks) | CIDR blocks allowed for ingress security group access (use either this OR ingress\_allowed\_prefix\_list\_ids, not both) | `list(string)` | `[]` | no |
| <a name="input_ingress_allowed_prefix_list_ids"></a> [ingress\_allowed\_prefix\_list\_ids](#input\_ingress\_allowed\_prefix\_list\_ids) | Prefix list IDs allowed for ingress security group access (use either this OR ingress\_allowed\_cidr\_blocks, not both) | `list(string)` | `[]` | no |
| <a name="input_instance_profile_name"></a> [instance\_profile\_name](#input\_instance\_profile\_name) | IAM instance profile name (optional - will be created if not provided) | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"M6I_2XLARGE"` | no |
| <a name="input_keep_cluster_on_failure"></a> [keep\_cluster\_on\_failure](#input\_keep\_cluster\_on\_failure) | Keep cluster on failure | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for S3 bucket encryption (optional - only needed if using SSE-KMS) | `string` | `null` | no |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | NTP servers | `list(string)` | <pre>[<br/>  "pool.ntp.org"<br/>]</pre> | no |
| <a name="input_num_nodes"></a> [num\_nodes](#input\_num\_nodes) | Number of nodes in the cluster | `number` | `3` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region for the cloud cluster | `string` | `"us-west-2"` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs (optional - will be created if not provided) | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_use_placement_groups"></a> [use\_placement\_groups](#input\_use\_placement\_groups) | Whether to use placement groups for the cluster, this is recommended to be enabled | `bool` | `true` | no |
| <a name="input_vm_type"></a> [vm\_type](#input\_vm\_type) | VM type | `string` | `"EXTRA_DENSE"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloud_cluster_id"></a> [cloud\_cluster\_id](#output\_cloud\_cluster\_id) | The ID of the Rubrik Polaris cloud cluster |
| <a name="output_cloud_cluster_name"></a> [cloud\_cluster\_name](#output\_cloud\_cluster\_name) | The name of the Rubrik Polaris cloud cluster |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | The ARN of the IAM instance profile |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | The name of the IAM instance profile |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | The ARN of the IAM role |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | The ARN of the S3 bucket |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | The name of the S3 bucket |
| <a name="output_s3_policy_arn"></a> [s3\_policy\_arn](#output\_s3\_policy\_arn) | The ARN of the S3 access policy |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the security group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | The IDs of the security groups |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | The ID of the subnet used for the cluster |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
<!-- END_TF_DOCS -->
