# AWS Cloud Platform Demo

A production-grade AWS platform built to demonstrate cloud modernization — migrating from legacy single-server architecture to a fully automated, secure, and observable cloud-native platform.

## The Modernization Story

### Before (Legacy State)

- Single EC2 instance
- Manual SSH access (key pairs, port 22 open)
- Manual deployments (SSH in, git pull, restart)
- Single-AZ database, no failover
- Hardcoded credentials in config files
- Fixed capacity — over-provisioned for peak load
- No compliance baseline
- No cost visibility or tagging
- No audit trail of changes

### After (Modernized Platform)

- ECS Fargate — serverless containers, no servers to manage
- SSM Session Manager — zero SSH, zero key pairs
- GitHub Actions CI/CD — fully automated deployments
- RDS Multi-AZ — automatic failover, RPO=0, RTO<2min
- AWS Secrets Manager — credentials never in code
- Auto Scaling — min 1, max 4 tasks, CPU and memory targets
- CloudTrail + GuardDuty + AWS Config — continuous compliance
- 6-tag cost strategy — per-project cost allocation
- Terraform IaC — full platform reproducible in 20 minutes

## Modernization Gains

| Dimension | Legacy | Modernized | Improvement |
|---|---|---|---|
| Deployment | Manual SSH + git pull | GitHub Actions pipeline | Zero-touch, audited |
| Access | SSH key pairs, port 22 | SSM Session Manager | Zero-trust, logged |
| Database HA | Single-AZ | Multi-AZ, auto failover | RTO < 2 minutes |
| Credentials | Hardcoded in config | AWS Secrets Manager | Rotation-ready |
| Scaling | Fixed capacity | Auto scaling 1-4 tasks | Cost-efficient |
| Compliance | Manual audits | Continuous Config rules | Real-time |
| Cost visibility | None | 6 tags, Cost Explorer | Per-project chargeback |
| Reproducibility | Snowflake server | Terraform IaC | Full rebuild in 20 min |
| Audit trail | None | CloudTrail + CloudWatch | Every action logged |

## Architecture

    Internet
        │  HTTP/HTTPS
        ▼
    ┌─────────────────────────────────────────────────────┐
    │  VPC  10.0.0.0/16  (us-east-1)                     │
    │                                                     │
    │  ┌── Public subnets (us-east-1a + 1b) ──────────┐  │
    │  │  ALB (ports 80/443)    NAT Gateway            │  │
    │  └───────────────────────────────────────────────┘  │
    │              │ port 8080                            │
    │  ┌── Private subnets (us-east-1a + 1b) ─────────┐  │
    │  │  ECS Fargate            EC2 t4g.micro         │  │
    │  │  256 CPU / 512MB        Graviton2 / SSM only  │  │
    │  │                                               │  │
    │  │  RDS PostgreSQL 15 Primary  <-> RDS Standby  │  │
    │  │  Multi-AZ / encrypted        auto failover   │  │
    │  └───────────────────────────────────────────────┘  │
    │                                                     │
    │  S3+KMS  |  Secrets Manager  |  CloudWatch         │
    │  CloudTrail  |  GuardDuty  |  AWS Config           │
    └─────────────────────────────────────────────────────┘
             │
             ▼
    GitHub Actions CI/CD
    push -> fmt -> validate -> plan -> apply . Docker -> ECR

## What's Built

### Networking
- VPC 10.0.0.0/16 across 2 AZs (us-east-1a, us-east-1b)
- Public subnets: ALB and NAT Gateway only
- Private subnets: all compute and data, no public IPs
- Security group chaining: internet -> ALB SG -> App SG only

### Compute
- ECS Fargate cluster with Container Insights enabled
- Auto scaling: CPU target 60%, Memory target 70%, max 4 tasks
- EC2 t4g.micro (Graviton2, 20% cheaper than Intel)
- SSM Session Manager — no SSH keys, no bastion host

### Containers
- ECR private repository with vulnerability scanning on push
- Docker images tagged with git SHA (immutable) + latest
- Lifecycle policy: retain last 10 images

### Database
- RDS PostgreSQL 15, Multi-AZ, db.t3.micro
- Synchronous replication — RPO = 0 for AZ failures
- Automatic failover — RTO < 2 minutes
- Encrypted storage (gp3), 7-day automated backups
- No public access — private subnet only

### Security
- AWS Secrets Manager: DB credentials, full connection details
- ECS task role: least-privilege access to secrets only
- CloudTrail: multi-region, log file validation, S3 delivery
- GuardDuty: threat detection with S3 + EBS malware scanning
- AWS Config: 3 continuous compliance rules
  - S3 buckets must block public read
  - EBS volumes must be encrypted
  - Root account must have MFA enabled

### Storage
- S3 with customer managed KMS encryption
- Versioning + lifecycle policy (STANDARD -> IA at 30d -> delete at 90d)
- Bucket policies: deny unencrypted uploads + deny non-HTTPS

### Observability
- CloudWatch alarms: ECS CPU >80%, Memory >80%, ALB 5xx >10, Unhealthy hosts >0
- CloudWatch dashboard: ECS metrics, ALB metrics, alarm status
- Container logs: /ecs/aws-cloud-platform-demo (30-day retention)

### Cost Management
- Provider default_tags: 6 tags on every resource automatically
- Project, Environment, ManagedBy, Owner, CostCenter, Repository
- Enables Cost Explorer chargeback by project and owner
- Graviton2 compute (20% cost reduction vs Intel)
- Fargate: pay per task-second, not idle EC2 hours
- S3 lifecycle policies prevent unbounded versioning costs

### CI/CD Pipeline
- Triggers on push to main and pull requests
- Terraform: fmt -> validate -> plan -> apply (only when changes detected)
- Docker: build -> tag with git SHA -> push to ECR
- AWS credentials in GitHub Secrets — never in code
- Every infrastructure change tied to a git commit

## Module Structure

    terraform/
    ├── main.tf                    # Root module, provider with default_tags
    ├── variables.tf
    ├── outputs.tf
    └── modules/
        ├── vpc/                   # Networking: VPC, subnets, IGW, NAT
        ├── security/              # Security groups, IAM, instance profile
        ├── compute/               # EC2, ECR repository
        ├── ecs/                   # ECS Fargate, ALB, auto scaling
        ├── rds/                   # RDS Multi-AZ, Secrets Manager
        ├── storage/               # S3, KMS
        ├── security-baseline/     # CloudTrail, GuardDuty, Config
        └── cloudwatch/            # Alarms, dashboard

## Local Development

### Prerequisites
- AWS CLI with demo profile configured
- Terraform >= 1.15
- Docker

### Deploy

    cd terraform
    AWS_PROFILE=demo TF_VAR_db_password='your-password' terraform init
    AWS_PROFILE=demo TF_VAR_db_password='your-password' terraform plan
    AWS_PROFILE=demo TF_VAR_db_password='your-password' terraform apply

### Connect to EC2 (no SSH)

    aws ssm start-session --target <instance-id> --profile demo

### Destroy all resources

    cd terraform
    AWS_PROFILE=demo TF_VAR_db_password='your-password' terraform destroy

## Key Interview Points

On modernization:
"The core shift is from mutable infrastructure managed manually to immutable infrastructure managed as code. Every resource is reproducible from a git commit. Every deployment is automated. Every access is audited."

On security:
"Zero SSH anywhere. SSM Session Manager for access, Secrets Manager for credentials, security group chaining so nothing is directly internet-reachable. CloudTrail logs every API call — in insurance that audit trail is a compliance requirement."

On reliability:
"Multi-AZ RDS gives us RPO of zero and RTO under 2 minutes for AZ failures. ECS auto scaling handles load spikes without manual intervention. Two AZs means no single datacenter failure takes us down."

On cost:
"Graviton2 instances, Fargate pay-per-use, S3 lifecycle policies, and mandatory tagging for cost allocation. FinOps discipline is built into the platform, not bolted on later."