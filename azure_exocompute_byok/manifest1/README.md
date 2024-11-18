# Manifest1 Module
The manifest1 module uses a `null_resource` with a `local-exec` provisioner to
run `kubectl` to apply the manifest received from the 
`polaris_azure_exocompute_cluster_attachment` resource. The computer running the
Terraform apply operation needs to have the `az` and `kubectl` command line
tools installed.

Note, in this example, the AKS cluster credentials are never removed from the
computer which runs Terraform.
