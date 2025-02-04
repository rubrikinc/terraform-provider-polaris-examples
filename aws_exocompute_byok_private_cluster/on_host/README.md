# On Host Configuration
This configuration onboards an AWS account to RSC, spins up a private AWS EKS
cluster and creates a jumpbox in the public subnet of the VPC. After this
configuration has been applied with Terraform, one of the two manifest modules
on the jumpbox needs to be applied to finalize the EKS cluster setup.
