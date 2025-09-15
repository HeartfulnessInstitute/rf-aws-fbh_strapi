terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Main configuration using modules
module "networking" {
  source = "./modules/networking"
  
  vpc_cidr     = var.vpc_cidr
  project_name = var.project_name
  environment  = var.environment
  
  tags = local.common_tags
}

module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id       = module.networking.vpc_id
  project_name = var.project_name
  environment  = var.environment
  
  tags = local.common_tags
}

module "rds" {
  source = "./modules/rds"
  
  vpc_id              = module.networking.vpc_id
  private_subnet_ids  = module.networking.private_subnet_ids
  security_group_id   = module.security_groups.rds_security_group_id
  db_password         = var.db_password
  project_name        = var.project_name
  environment         = var.environment
  
  tags = local.common_tags
}

module "s3" {
  source = "./modules/s3"
  
  project_name = var.project_name
  environment  = var.environment
  app_name     = var.app_name
  
  tags = local.common_tags
}

module "acm_cert" {
  source = "./modules/acm_cert"
  
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
  project_name    = var.project_name
  environment     = var.environment
  
  tags = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"
  
  vpc_id                = module.networking.vpc_id
  public_subnet_id      = module.networking.public_subnet_ids[0]
  security_group_id     = module.security_groups.ec2_security_group_id
  iam_instance_profile  = module.s3.instance_profile_name
  key_pair_name         = var.key_pair_name
  project_name          = var.project_name
  environment           = var.environment
  app_name              = var.app_name
  
  # Environment variables for Strapi
  rds_endpoint    = module.rds.endpoint
  db_name         = module.rds.db_name
  db_username     = module.rds.username
  db_password     = var.db_password
  s3_bucket_name  = module.s3.bucket_name
  
  tags = local.common_tags
}

module "alb" {
  source = "./modules/alb"
  
  vpc_id              = module.networking.vpc_id
  public_subnet_ids   = module.networking.public_subnet_ids
  security_group_id   = module.security_groups.alb_security_group_id
  certificate_arn     = module.acm_cert.certificate_arn
  ec2_instance_id     = module.ec2.instance_id
  project_name        = var.project_name
  environment         = var.environment
  
  # ALB specific configurations from environment
  internal                   = var.internal
  enable_deletion_protection = var.enable_deletion_protection
  load_balancer_name         = var.load_balancer_name
  port                      = var.port
  target_group_protocol     = var.target_group_protocol
  target_type               = var.target_type
  target_group_port         = var.target_group_port
  health_check_path         = var.health_check_path
  health_check_protocol     = var.health_check_protocol
  health_check_interval     = var.health_check_interval
  health_check_timeout      = var.health_check_timeout
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  listener_port             = var.listener_port
  listener_protocol         = var.listener_protocol
  
  # Domain configuration
  domain_name         = var.domain_name
  route53_zone_id     = var.route53_zone_id
  
  tags = local.common_tags
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    AppName     = var.app_name
    ManagedBy   = "Terraform"
  }
}