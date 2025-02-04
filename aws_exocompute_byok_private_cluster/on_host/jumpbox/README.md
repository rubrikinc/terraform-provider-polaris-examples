# Jumpbox module
The Jumpbox module spins up an AWS EC2 instance in the public subnet of the
VPC with the on_jumpbox configuration and all required command line tools
installed. The jumpbox is used to apply Terraform configurations which requires
access to the private EKS cluster. The Terraform state of the jumpbox is kept
in an AWS S3 bucket.
