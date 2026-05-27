variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "aws-cloud-platform-demo"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
