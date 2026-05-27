# DB Subnet Group - tells RDS which subnets it can use
resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project}-db-subnet-group"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Security Group for RDS - only accepts traffic from app security group
resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-sg"
  description = "Security group for RDS - accepts traffic from app only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from app only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-rds-sg"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "main" {
  name   = "${var.project}-db-params"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  tags = {
    Name        = "${var.project}-db-params"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# RDS PostgreSQL Multi-AZ Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project}-db"

  engine         = "postgres"
  engine_version = "15"
  instance_class = "db.t3.micro"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.main.name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  deletion_protection      = false
  skip_final_snapshot      = true
  delete_automated_backups = true

  publicly_accessible = false

  tags = {
    Name        = "${var.project}-db"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
