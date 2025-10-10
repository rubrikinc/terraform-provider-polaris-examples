# AWS Exocompute

This module creates an RSC Exocompute configuration for running Exocompute workloads in AWS.

## Usage

```terraform
module "aws_cnp_account" {
  source = "."

  cloud_account_id          = "d7984bca-db41-40ba-98ef-c56c4aef6c23"
  cluster_security_group_id = "sg-267288cc1f4a4be6a"
  node_security_group_id    = "sg-03aa0f1db4fb1b816"
  region                    = "us-east-2"
  subnet1_id                = "subnet-2f261b5f754ab1dcb"
  subnet2_id                = "subnet-1efb0142c8604a6ca"
  vpc_id                    = "vpc-0e2f6d1ed6a3d8571"
}
```

Note, the `cluster_security_group_id` and `node_security_group_id` input variables must be specified if the
`rubrikinc/polaris-cloud-native-exocompute-networking/aws` Terraform module is used to create the VPC resources.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.11.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=6.0.0 |
| <a name="requirement_polaris"></a> [polaris](#requirement\_polaris) | >=1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=6.0.0 |
| <a name="provider_polaris"></a> [polaris](#provider\_polaris) | >=1.0.0 |

## Resources

| Name | Type |
|------|------|
| [polaris_aws_exocompute.configuration](https://registry.terraform.io/providers/rubrikinc/polaris/latest/docs/resources/aws_exocompute) | resource |
| [aws_regions.regions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_account_id"></a> [cloud\_account\_id](#input\_cloud\_account\_id) | RSC cloud account ID of the AWS account hosting Exocompute. | `string` | n/a | yes |
| <a name="input_cluster_security_group_id"></a> [cluster\_security\_group\_id](#input\_cluster\_security\_group\_id) | AWS cluster / control plane security group ID. | `string` | `null` | no |
| <a name="input_node_security_group_id"></a> [node\_security\_group\_id](#input\_node\_security\_group\_id) | AWS node / worker security group ID. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to run Exocompute in. | `string` | n/a | yes |
| <a name="input_subnet1_id"></a> [subnet1\_id](#input\_subnet1\_id) | AWS subnet 1 ID. | `string` | n/a | yes |
| <a name="input_subnet2_id"></a> [subnet2\_id](#input\_subnet2\_id) | AWS subnet 2 ID. | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | AWS VPC ID. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_id"></a> [configuration\_id](#output\_configuration\_id) | RSC Exocompute configuration ID. |
<!-- END_TF_DOCS -->
