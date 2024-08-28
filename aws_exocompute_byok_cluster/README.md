# AWS Exocompute BYOK Cluster Example
The AWS Exocompute BYOK Cluster example shows how an AWS EKS cluster can be used
for hosting RSC Exocompute workloads.

The example uses the `kubernetes_manifest` Terraform resource to deploy K8s
resources to the EKS cluster. Because of limitations in `kubernetes_manifest`
resource, the EKS cluster must be created before the full Terraform
configuration is applied.

To create the EKS cluster before the full Terraform configuration is applied the
Terraform `-target` option can be used. Start by running:
```bash
$ terraform apply -target=module.eks_cluster
```
This will onboard the AWS account using the `account` module and create the EKS
cluster using the `eks_cluster` module. Next, apply the rest of the Terraform
configuration:
```bash
$ terraform apply
```
