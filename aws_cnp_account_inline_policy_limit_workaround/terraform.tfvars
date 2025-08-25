# Example RSC features to onboard the AWS account with.

features = {
  CLOUD_NATIVE_ARCHIVAL = {
    permission_groups = [
      "BASIC"
    ]
  },
  CLOUD_NATIVE_PROTECTION = {
    permission_groups = [
      "BASIC"
    ]
  },
  EXOCOMPUTE = {
    permission_groups = [
      "BASIC",
      "RSC_MANAGED_CLUSTER"
    ]
  },
}
