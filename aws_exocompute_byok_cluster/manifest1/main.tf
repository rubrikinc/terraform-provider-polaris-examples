terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
  }
}

# Make sure the kubectl configuration file contains the EKS cluster credentials.
resource "null_resource" "update_kubeconfig" {
  triggers = {
    manifest = sha256(var.manifest)
  }

  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${var.eks_cluster_name} --region ${var.eks_cluster_region}"
  }
}

# Update the EKS cluster according to the manifest.
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
