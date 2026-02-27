# Used for region input validation.
data "aws_regions" "regions" {
  all_regions = true
}

data "polaris_aws_account" "account" {
  cloud_account_id = var.cloud_account_id

  lifecycle {
    postcondition {
      condition     = contains([for f in self.feature : f.name], "EXOCOMPUTE")
      error_message = "The cloud account must have the EXOCOMPUTE RSC feature enabled."
    }
  }
}

# Create an Exocompute configuration.
resource "polaris_aws_exocompute" "configuration" {
  account_id                = var.cloud_account_id
  cluster_access            = var.cluster_access
  cluster_security_group_id = var.cluster_security_group_id
  node_security_group_id    = var.node_security_group_id
  region                    = var.region
  vpc_id                    = var.vpc_id

  subnets = [
    var.subnet1_id,
    var.subnet2_id,
  ]
}
