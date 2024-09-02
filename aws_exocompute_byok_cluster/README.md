# AWS Exocompute BYOK Cluster Example
The AWS Exocompute BYOK cluster example shows how an AWS EKS cluster can be used
for hosting RSC Exocompute workloads.

There are two different modules for deploying the K8s manifest received from
RSC, manifest1 and manifest2. The recommended module is manifest1 as it will
always deploy the K8s resources in the manifest in the correct order. The
downside with manifest1 is that there is no way to manage the K8s resources
deployed using Terraform. The manifest2 module allows you manage the K8s
resources using Terraform, however the deployment order is based on the K8s
resource kinds and not the actual order in the manifest. More details can be
found in each module's README file.
