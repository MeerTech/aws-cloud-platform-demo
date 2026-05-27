# AWS Cloud Platform Demo

Production-grade AWS platform built with Terraform IaC, ECS Fargate, GitHub Actions CI/CD, and a full security baseline.

## Architecture
## What's Built

### Networking (VPC)
- VPC `10.0.0.0/16` across 2 availability zones (us-east-1a, us-east-1b)
- Public subnets for ALB and NAT Gateway
- Private subnets for ECS tasks and EC2
- Internet Gateway + NAT Gateway (outbound-only for private resources)

### Security
- ALB security group — inbound HTTP/HTTPS from internet only
- App security group — inbound only from ALB SG (never direct from internet)
- IAM roles with least-privilege policies
- SSM Session Manager for EC2 access — no SSH keys, no bastion host

### Compute
- ECS Fargate cluster with Container Insights
- Fargate task: 256 CPU / 512MB memory
- EC2 t4g.micro (Graviton2) in private subnet — SSM access only
- Application Load Balancer with health checks

### Containers
- ECR private repository with image scanning on push
- Lifecycle policy: retain last 10 images
- Docker image tagged with git SHA (immutable) + latest

### Storage
- S3 app data bucket with customer managed KMS encryption
- Versioning enabled, lifecycle policy (STANDARD → STANDARD_IA at 30d → delete at 90d)
- Bucket policies: deny unencrypted uploads + deny non-SSL requests

### Security Baseline
- **CloudTrail**: multi-region trail, log file validation, S3 delivery
- **GuardDuty**: threat detection with S3 logs + EBS malware scanning
- **AWS Config**: continuous compliance with 3 rules:
  - S3 buckets must block public read
  - EBS volumes must be encrypted
  - Root account must have MFA enabled

### Observability
- CloudWatch alarms: ECS CPU >80%, ECS Memory >80%, ALB 5xx >10, Unhealthy hosts >0
- CloudWatch dashboard: ECS metrics, ALB metrics, alarm status
- ECS container logs: `/ecs/aws-cloud-platform-demo` (30 day retention)

### CI/CD Pipeline (GitHub Actions)
- Triggers on push to `main` and pull requests
- Steps: `terraform fmt` → `terraform validate` → `terraform plan` → `terraform apply`
- Apply runs only when plan detects actual changes (exit code 2)
- Docker build + push to ECR on every merge to main
- AWS credentials stored as GitHub secrets — never in code

## Repository Structure
## Local Development

### Prerequisites
- AWS CLI configured with `demo` profile
- Terraform >= 1.15
- Docker

### Deploy
```bash
cd terraform
AWS_PROFILE=demo terraform init
AWS_PROFILE=demo terraform plan
AWS_PROFILE=demo terraform apply
```

### Connect to EC2 (no SSH needed)
```bash
aws ssm start-session --target <instance-id> --profile demo
```

### Destroy
```bash
cd terraform
AWS_PROFILE=demo terraform destroy
```

## Tech Stack

| Layer | Technology |
|---|---|
| IaC | Terraform 1.15 |
| Cloud | AWS (us-east-1) |
| Containers | Docker + ECS Fargate |
| Registry | Amazon ECR |
| CI/CD | GitHub Actions |
| Networking | VPC, ALB, NAT Gateway |
| Security | GuardDuty, CloudTrail, AWS Config |
| Observability | CloudWatch |
| Access | SSM Session Manager |
| Encryption | KMS, AES256 |
