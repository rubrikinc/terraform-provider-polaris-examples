terraform {
  required_version = ">=1.5.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.26.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.25.0"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "=0.8.0-beta.15"
    }
  }
}

provider "aws" {}

provider "kubernetes" {
  host                   = module.cluster.aws_eks_cluster_endpoint
  cluster_ca_certificate = module.cluster.aws_eks_cluster_ca_certificate
  token                  = module.cluster.aws_eks_cluster_token
}

provider "polaris" {}
