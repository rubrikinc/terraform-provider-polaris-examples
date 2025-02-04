data "archive_file" "on_jumpbox" {
  type        = "zip"
  source_dir  = "${path.module}/../../on_jumpbox"
  output_path = "${path.module}/files/on_jumpbox.zip"
  excludes    = ["**/README.md"]

  depends_on = [
    local_file.kubeconfig,
    local_file.providers,
    local_file.tfvars,
  ]
}

data "local_file" "on_jumpbox_zip" {
  filename = data.archive_file.on_jumpbox.output_path

  # Note this is needed so that the zip file is updated before it's attached
  # to the EC2 image as user data.
  depends_on = [
    local_file.kubeconfig,
    local_file.providers,
    local_file.tfvars,
  ]
}

resource "local_file" "kubeconfig" {
  filename        = "${path.module}/../../on_jumpbox/kubeconfig"
  file_permission = "0644"

  content = templatefile("${path.module}/kubeconfig.tftpl", {
    aws_access_key                 = var.aws_access_key
    aws_secret_key                 = var.aws_secret_key
    aws_region                     = var.aws_region
    aws_eks_cluster_ca_certificate = base64encode(var.aws_eks_cluster_ca_certificate)
    aws_eks_cluster_endpoint       = var.aws_eks_cluster_endpoint
    aws_eks_cluster_name           = var.aws_eks_cluster_name
    aws_eks_cluster_region         = var.aws_eks_cluster_region
  })
}

resource "local_file" "providers" {
  filename        = "${path.module}/../../on_jumpbox/providers.tf"
  file_permission = "0644"

  content = templatefile("${path.module}/providers.tftpl", {
    aws_access_key = var.aws_access_key
    aws_secret_key = var.aws_secret_key
    aws_region     = var.aws_region
    jumpbox_data   = aws_s3_bucket.jumpbox_data.id
  })
}

resource "local_file" "tfvars" {
  filename        = "${path.module}/../../on_jumpbox/terraform.tfvars"
  file_permission = "0644"

  content = templatefile("${path.module}/tfvars.tftpl", {
    aws_eks_cluster_ca_certificate = var.aws_eks_cluster_ca_certificate
    aws_eks_cluster_endpoint       = var.aws_eks_cluster_endpoint
    aws_eks_cluster_name           = var.aws_eks_cluster_name
    jumpbox_data                   = aws_s3_bucket.jumpbox_data.id
  })
}
