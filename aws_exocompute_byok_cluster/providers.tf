terraform {
  required_version = ">=1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.26.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.32.0"
    }
    polaris = {
      source  = "terraform.rubrik.com/rubrikinc/polaris"
      version = ">=0.8.0"
    }
  }
}

provider "aws" {}

provider "kubernetes" {
  host                   = module.cluster.aws_eks_cluster_endpoint
  cluster_ca_certificate = module.cluster.aws_eks_cluster_ca_certificate
  token                  = module.cluster.aws_eks_cluster_token
}

provider "polaris" {
  credentials = <<-EOS
    {
      "client_id": "client|2b61c3e3-ace8-46b4-b8c5-e42cc0ad3718",
      "client_secret": "V9LSGqCsffdq57eevWYg20h81zxDkz4oS7Z68j9hVYaNrRO1jB9xtBG9NY2lFMTW",
      "name": "terraform-test",
      "access_token_uri": "https://saketh-jedi.dev-080.my.rubrik-lab.com/api/client_token"
    }
    EOS
}

# provider "polaris" {
#   credentials = <<-EOS
#     {
#       "client_id" : "client|14c3ee23-82b7-4201-a281-703d90f6c52a",
#       "client_secret" : "4EucJ9NuJNwvgOUMxPkN2W1Whr_brLilD1KPpBPYkQdOFTdRMrhvoe8K0dgIXaKD",
#       "name" : "Terraform",
#       "access_token_uri" : "https://lakshit.dev-057.my.rubrik-lab.com/api/client_token"
#     }
#     EOS
# }
