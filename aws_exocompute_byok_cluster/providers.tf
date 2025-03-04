terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.26.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.32.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.2.2"
    }
    polaris = {
      source  = "rubrikinc/polaris"
      version = "~>1.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~>0.12.0"
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
