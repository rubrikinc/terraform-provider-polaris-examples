# Make sure the kubectl configuration file contains the AKS cluster credentials.
resource "null_resource" "update_kubeconfig" {
  triggers = {
    manifest = sha256(var.manifest)
  }

  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${var.aks_cluster_resource_group} --name ${var.aks_cluster_name}"
  }
}

# Update the AKS cluster according to the manifest.
resource "null_resource" "update_cluster" {
  triggers = {
    manifest = sha256(var.manifest)
  }

  provisioner "local-exec" {
    command = "echo $MANIFEST | base64 -d | kubectl apply -f -"

    environment = {
      MANIFEST = base64encode(var.manifest)
    }
  }

  depends_on = [
    null_resource.update_kubeconfig,
  ]
}
