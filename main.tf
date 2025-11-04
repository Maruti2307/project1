############################################
# Provider Configuration
############################################
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

############################################
# VPC Module
############################################
module "vpc" {
  source               = "./vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
}

############################################
# Security Groups
############################################
module "security_groups" {
  source     = "./security-groups"
  vpc_id     = module.vpc.vpc_id
  alb_sg_ingress_cidr = var.alb_sg_ingress_cidr
}

############################################
# Bastion Host
############################################
module "bastion" {
  source            = "./bastion"
  subnet_id         = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.security_groups.bastion_sg_id]
  key_name          = var.key_name
  ami_id            = var.bastion_ami
  instance_type     = var.bastion_instance_type
}

############################################
# Application Load Balancer
############################################
module "alb" {
  source            = "./alb"
  name              = "app-alb"
  vpc_id            = module.vpc.vpc_id
  subnets           = module.vpc.public_subnets
  security_groups   = [module.security_groups.alb_sg_id]
  target_group_port = 80
}

############################################
# EC2 Auto Scaling Group (Application Tier)
############################################
module "ec2" {
  source              = "./ec2"
  vpc_id              = module.vpc.vpc_id
  private_subnets     = module.vpc.private_subnets
  alb_target_group_arn = module.alb.target_group_arn
  ec2_sg_id           = module.security_groups.ec2_sg_id
  key_name            = var.key_name
  instance_type       = var.ec2_instance_type
  ami_id              = var.ec2_ami
}

############################################
# RDS Database
############################################
module "rds" {
  source              = "./rds"
  db_subnet_ids       = module.vpc.private_subnets
  vpc_security_groups = [module.security_groups.rds_sg_id]
  db_name             = var.db_name
  username            = var.db_username
  password            = var.db_password
  instance_class      = var.db_instance_class
  allocated_storage   = var.db_allocated_storage
}

############################################
# Outputs
############################################
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "rds_endpoint" {
  value = module.rds.db_endpoint
}
