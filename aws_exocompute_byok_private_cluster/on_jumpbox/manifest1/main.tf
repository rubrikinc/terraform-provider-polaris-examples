resource "null_resource" "update_cluster" {
  triggers = {
    manifest = sha256(var.rsc_manifest)
  }

  provisioner "local-exec" {
    command = "echo $MANIFEST | base64 -d | kubectl --kubeconfig=${path.root}/kubeconfig apply -f -"

    environment = {
      MANIFEST = base64encode(var.rsc_manifest)
    }
  }
}
