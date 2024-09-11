# AWS Exocompute BYOK Private Cluster Example
This example shows how a private AWS EKS cluster can be used to host RSC
Exocompute workloads. A private AWS EKS cluster is a cluster which has the
public API-server endpoint disabled. Because of this, the endpoint can only be
reached from inside the VPC. To work around this limitation, the example deploys
a jumpbox inside the public subnet of the VPC. The jumpbox is used to run
Terraform operations which requires access to the endpoint, such as applying a
Kubernetes manifest.

Note, the RSC images needs to be synchronized across from the RSC container
registry to the ECR registry after the on_host configuration has been applied.
The reason is the AWS account is granted access to the RSC registry when the
`polaris_aws_private_container_registry` resource is created.
