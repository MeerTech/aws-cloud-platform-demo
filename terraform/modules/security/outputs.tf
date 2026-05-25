output "alb_sg_id" {
  description = "Security group ID for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "Security group ID for application servers"
  value       = aws_security_group.app.id
}

output "ec2_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "ec2_role_arn" {
  description = "IAM role ARN for EC2 instances"
  value       = aws_iam_role.ec2_role.arn
}
