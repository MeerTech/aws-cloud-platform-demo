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
    profile      = "demo"
    use_lockfile = true
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "demo"
}

module "vpc" {
  source = "./modules/vpc"

  project     = var.project
  environment = var.environment
}
