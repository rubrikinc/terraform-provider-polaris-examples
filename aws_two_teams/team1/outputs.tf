output "instance_profiles" {
  value = {
    for k, v in aws_iam_instance_profile.profile : k => v.arn
  }
}

output "roles" {
  value = {
    for k, v in aws_iam_role.role : k => v.arn
  }
}
