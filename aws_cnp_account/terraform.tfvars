# Example RSC features to onboard the AWS account with.

features = [
  {
    name = "CLOUD_NATIVE_ARCHIVAL"
    permission_groups = [
      "BASIC"
    ]
  },
  {
    name = "CLOUD_NATIVE_PROTECTION"
    permission_groups = [
      "BASIC"
    ]
  },
  {
    name = "EXOCOMPUTE"
    permission_groups = [
      "BASIC",
      "RSC_MANAGED_CLUSTER"
    ]
  },
]
