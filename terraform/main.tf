terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "aws-cloud-platform-demo-tfstate-433134836357"
    key          = "platform/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "vpc" {
  source      = "./modules/vpc"
  project     = var.project
  environment = var.environment
}

module "security" {
  source      = "./modules/security"
  project     = var.project
  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

module "compute" {
  source                    = "./modules/compute"
  project                   = var.project
  environment               = var.environment
  ami_id                    = "ami-0576ef8e344fbf536"
  instance_type             = "t4g.micro"
  private_subnet_ids        = module.vpc.private_subnet_ids
  app_sg_id                 = module.security.app_sg_id
  ec2_instance_profile_name = module.security.ec2_instance_profile_name
}

module "storage" {
  source      = "./modules/storage"
  project     = var.project
  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id
}

module "ecs" {
  source             = "./modules/ecs"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  alb_sg_id          = module.security.alb_sg_id
  app_sg_id          = module.security.app_sg_id
  ecr_repository_url = module.compute.ecr_repository_url
}
