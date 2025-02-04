# EKS Cluster Module
The EKS cluster module spins up an AWS EKS cluster to host RSC Exocompute
workloads. One of the manifest submodules in the on_jumpbox configuration must
be applied, using the jumpbox in the VPC, before the cluster can host Exocompute
workloads.
