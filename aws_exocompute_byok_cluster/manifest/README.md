# Manifests Module
The Manifest module parses the K8s manifest received from the
`polaris_aws_exocompute_cluster_attachment` resource and creates TF
`kubernetes_manifest` resources from the content. Note, this module takes care
of creating the K8s resources in the manifest in the correct order.

Due to this module using the `kubernetes_manifest` resource it cannot be used by
Terraform until the K8s cluster has been created. The reason for this is that
`kubernetes_manifest` requires access to the K8s cluster during Terraform plan
time.

To work around this start by creating the K8s cluster using the Terraform
`-target` command line option:
```bash
$ terraform apply -target=module.eks_cluster
```

This will onboard the AWS account using the `account` module and create the AWS
EKS cluster using the `eks_cluster` module. Next, apply the rest of the
Terraform configuration:
```bash
$ terraform apply
```
