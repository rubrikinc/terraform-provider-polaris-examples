resource "aws_autoscaling_group" "cluster" {
  name             = "${var.aws_name_prefix}-autoscaling-group-${var.aws_eks_cluster_region}"
  min_size         = 1
  max_size         = var.aws_eks_autoscaling_max_size
  desired_capacity = 1
  vpc_zone_identifier = [
    aws_subnet.exocompute_subnet_1.id,
    aws_subnet.exocompute_subnet_2.id
  ]

  launch_template {
    id      = aws_launch_template.worker.id
    version = "$Latest"
  }
}
