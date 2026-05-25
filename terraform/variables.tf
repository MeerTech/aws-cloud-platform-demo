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
