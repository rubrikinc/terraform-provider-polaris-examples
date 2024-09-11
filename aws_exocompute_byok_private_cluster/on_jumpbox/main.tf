data "aws_s3_object" "manifest" {
  bucket = var.jumpbox_data
  key    = "manifest"
}

# One of the two manifest modules below needs to be enabled to deploy the
# Kubernetes resources from the RSC generated manifest to the EKS cluster.

# Deploy K8s resources from the manifest using kubectl.
module "manifest" {
  source = "./manifest1"

  rsc_manifest = data.aws_s3_object.manifest.body
}

# Deploy K8s resources from the manifest using the Kubernetes TF provider.
# module "manifest" {
#   source = "./manifest2"
#
#   aws_eks_cluster_ca_certificate = var.aws_eks_cluster_ca_certificate
#   aws_eks_cluster_endpoint       = var.aws_eks_cluster_endpoint
#   aws_eks_cluster_name           = var.aws_eks_cluster_name
#   rsc_manifest                   = data.aws_s3_object.manifest.body
# }
