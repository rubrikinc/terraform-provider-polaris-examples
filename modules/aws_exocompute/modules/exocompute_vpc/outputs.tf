output "cluster_security_group_id" {
  description = "AWS cluster / control plane security group ID."
  value       = aws_security_group.cluster.id
}

output "node_security_group_id" {
  description = "AWS node / worker security group ID."
  value       = aws_security_group.node.id
}

output "subnet1_id" {
  description = "AWS subnet 1 ID."
  value       = aws_subnet.subnet1.id
}

output "subnet2_id" {
  description = "AWS subnet 2 ID."
  value       = aws_subnet.subnet2.id
}

output "pod_subnet1_id" {
  description = "AWS pod subnet 1 ID."
  value       = try(aws_subnet.pod_subnet1[0].id, null)
}

output "pod_subnet2_id" {
  description = "AWS pod subnet 2 ID."
  value       = try(aws_subnet.pod_subnet2[0].id, null)
}

output "vpc_id" {
  description = "AWS VPC ID."
  value       = aws_vpc.vpc.id
}
