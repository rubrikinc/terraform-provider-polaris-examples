data "aws_eks_cluster_auth" "exocompute_cluster_auth" {
  name = "${var.aws_name_prefix}-eks-cluster"
}

resource "kubernetes_config_map" "aws_auth_configmap" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }
  data = {
    mapRoles = <<YAML
- rolearn: ${var.aws_eks_worker_node_role_arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
- rolearn: ${var.aws_iam_cross_account_role_arn}
  username: rubrik
  groups:
    - system:masters
YAML
  }
}
