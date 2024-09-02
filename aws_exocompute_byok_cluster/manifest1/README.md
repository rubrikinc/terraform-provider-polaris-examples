# Manifests Module
The manifest1 module uses a `null_resource` with a `local-exec` provisioner to
run `kubectl` to apply the manifest received from the 
`polaris_aws_exocompute_cluster_attachment` resource. The computer running the
Terraform apply operation needs to have the `aws` and `kubectl` command line
tools installed.

Note, in this example, the EKS cluster credentials are never removed from the
computer which runs Terraform.
