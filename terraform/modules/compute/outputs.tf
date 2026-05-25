output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}

output "instance_private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.app.private_ip
}
