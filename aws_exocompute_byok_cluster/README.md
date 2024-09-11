# AWS Exocompute BYOK Cluster Example
This example shows how an AWS EKS cluster can be used to host RSC Exocompute
workloads.

There are two different Terraform modules for deploying the Kubernetes manifest
received from RSC, manifest1 and manifest2. The recommended module is manifest1
as it will always deploy the Kubernetes resources in the manifest in the correct
order. The downside of manifest1 is that there is no way to manage the
Kubernetes resources deployed using Terraform. The manifest2 module allows you
manage the Kubernetes resources using Terraform, however the deployment order
is based on the Kubernetes resource kinds and not the actual order in the
manifest. More details can be found in each module's README file.

Note, the RSC images need to be synchronized across from the RSC container
registry to the ECR registry after the `polaris_aws_private_container_registry`
resource has been created and before the manifest is applied. The reason is the
AWS account is granted access to the RSC registry when the
`polaris_aws_private_container_registry` resource is created.
