terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.32.0"
    }
  }
}

data "aws_eks_cluster_auth" "exocompute" {
  name = var.aws_eks_cluster_name
}

provider "kubernetes" {
  host                   = var.aws_eks_cluster_endpoint
  cluster_ca_certificate = var.aws_eks_cluster_ca_certificate
  token                  = data.aws_eks_cluster_auth.exocompute.token
}
