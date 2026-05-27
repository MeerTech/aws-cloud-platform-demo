output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.app.name
}

output "alb_arn_suffix" {
  description = "ALB ARN suffix for CloudWatch"
  value       = aws_lb.main.arn_suffix
}

output "target_group_arn_suffix" {
  description = "Target group ARN suffix for CloudWatch"
  value       = aws_lb_target_group.app.arn_suffix
}

output "autoscaling_min_capacity" {
  description = "Minimum ECS task count"
  value       = aws_appautoscaling_target.ecs.min_capacity
}

output "autoscaling_max_capacity" {
  description = "Maximum ECS task count"
  value       = aws_appautoscaling_target.ecs.max_capacity
}
