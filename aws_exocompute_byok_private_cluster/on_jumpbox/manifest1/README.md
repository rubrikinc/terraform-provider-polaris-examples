# Manifests Module
The manifest1 module uses a `null_resource` with a `local-exec` provisioner to
run `kubectl` to apply the manifest received from the 
`polaris_aws_exocompute_cluster_attachment` resource.
