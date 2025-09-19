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

# VPC / Networking (remote module)
module "vpc" {
  source = "git::https://github.com/HeartfulnessInstitute/tf-aws-vpc.git?ref=v1.0.0"
  
  name_prefix     = "${var.project_name}-${var.environment}"
  vpc_cidr        = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tags = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"
  public_subnet_id     = module.vpc.public_subnet_ids[0]
  security_group_id    = module.security_groups.ec2_security_group_id
  iam_instance_profile = module.s3.instance_profile_name
  key_pair_name        = var.key_pair_name
  project_name         = var.project_name
  environment          = var.environment
  app_name             = var.app_name
  db_password          = var.db_password
  s3_bucket_name       = module.s3.bucket_name

  tags = local.common_tags
}


# Security Groups (local)
module "security_groups" {
  source = "./modules/security_groups"
  
  vpc_id       = module.vpc.vpc_id
  project_name = var.project_name
  tags         = local.common_tags
}

# RDS (remote module - pass only supported inputs)
module "rds" {
  source = "git::https://github.com/HeartfulnessInstitute/tf-aws-rds.git?ref=master"

}

# S3 (local)
module "s3" {
  source = "./modules/s3"
  
  project_name = var.project_name
  environment  = var.environment
  app_name     = var.app_name
  
  tags = local.common_tags
}

# ACM Certificate (local)
module "acm_cert" {
  source = "./modules/acm_cert"
  
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
  project_name    = var.project_name
  environment     = var.environment
  
  tags = local.common_tags
}


# ALB (local)
module "alb" {
  source = "./modules/alb"
  
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_id   = module.security_groups.alb_security_group_id
  certificate_arn     = try(module.acm_cert.certificate_arn, "")
  ec2_instance_id     = module.ec2.instance_id
  project_name        = var.project_name
  environment         = var.environment
  
  internal                   = var.internal
  enable_deletion_protection = var.enable_deletion_protection
  load_balancer_name         = var.load_balancer_name
  target_group_protocol      = var.target_group_protocol
  target_type                = var.target_type
  target_group_port          = var.target_group_port
  health_check_path          = var.health_check_path
  health_check_protocol      = var.health_check_protocol
  health_check_interval      = var.health_check_interval
  health_check_timeout       = var.health_check_timeout
  health_check_healthy_threshold   = var.health_check_healthy_threshold
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  listener_port              = var.listener_port
  listener_protocol          = var.listener_protocol
  
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
  
  tags = local.common_tags
}
module "amplify" {
  source = "./modules/aws-amplify"

  app_name        = "${var.project_name}-${var.environment}-frontend"
  repository_url  = var.amplify_repository_url
  project_name    = var.project_name
  environment     = var.environment

  build_spec = var.amplify_build_spec
  framework  = var.amplify_framework
  platform   = var.amplify_platform

  environment_variables = merge(var.amplify_environment_variables, {
    NEXT_PUBLIC_STRAPI_URL = "https://${var.domain_name}"
    NEXT_PUBLIC_API_URL    = "https://${var.domain_name}/api"
    NEXT_PUBLIC_ENV        = var.environment
  })

  branches = var.amplify_branches
  domain_name = var.amplify_domain_name
  sub_domains = var.amplify_sub_domains
  custom_rules = var.amplify_custom_rules
  create_webhook = var.amplify_create_webhook
  webhook_branch_name = var.amplify_webhook_branch_name

  tags = local.common_tags
}
module "cdn" {
  source = "./modules/cdn"

  bucket_name                = module.s3.bucket_name
  bucket_id                  = module.s3.bucket_id
  bucket_arn                 = module.s3.bucket_arn
  bucket_regional_domain_name = module.s3.bucket_regional_domain_name
  
  acm_certificate_arn = var.cloudfront_acm_certificate_arn
  aliases             = var.cloudfront_aliases
  comment             = "CDN for ${var.project_name} ${var.environment}"
  
  tags = local.common_tags
}
# Common tags
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    AppName     = var.app_name
    ManagedBy   = "Terraform"
  }
}

