# Create an Exocompute configuration.
resource "polaris_aws_exocompute" "configuration" {
  account_id                = var.cloud_account_id
  cluster_access            = var.cluster_access
  cluster_security_group_id = var.cluster_security_group_id
  node_security_group_id    = var.node_security_group_id
  region                    = var.region
  vpc_id                    = var.vpc_id

  subnets = var.pod_subnet1_id == null && var.pod_subnet2_id == null ? [
    var.subnet1_id,
    var.subnet2_id,
  ] : null

  dynamic "subnet" {
    for_each = var.pod_subnet1_id != null || var.pod_subnet2_id != null ? [
      { subnet_id = var.subnet1_id, pod_subnet_id = var.pod_subnet1_id },
      { subnet_id = var.subnet2_id, pod_subnet_id = var.pod_subnet2_id },
    ] : []
    content {
      subnet_id     = subnet.value.subnet_id
      pod_subnet_id = subnet.value.pod_subnet_id
    }
  }
}
