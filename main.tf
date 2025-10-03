terraform {
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

module "vpc" {
  source = "./modules/vpc"
  
  environment  = var.environment
  project_name = var.project_name
  
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}b"]
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"
  
  environment  = var.environment
  project_name = var.project_name
  
  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  key_name            = var.key_name
  instance_type       = "t3.micro"
  
  depends_on = [module.vpc]
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  environment  = var.environment
  project_name = var.project_name
  
  vpc_id               = module.vpc.vpc_id
  private_subnet_ids   = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.ec2_security_group_id
  
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password
  
  depends_on = [module.vpc, module.ec2]
}
# CloudFront Module
module "cloudfront" {
  source = "./modules/cloudfront"
  
  environment  = var.environment
  project_name = var.project_name
  
  # Optional custom domain (leave empty to use CloudFront domain)
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
  
  # CloudFront settings
  price_class              = "PriceClass_100"  # US, Canada, Europe
  enable_logging          = false              # ← Disable logging to avoid ACL issues
  default_root_object     = "index.html"
  enable_ipv6            = true
  minimum_protocol_version = "TLSv1.2_2021"
  
  # Cache settings
  default_ttl = 3600    # 1 hour
  max_ttl     = 86400   # 24 hours
  min_ttl     = 0       # No minimum
  
  compress = true
}
# Call ALB module
module "alb" {
  source = "./modules/alb"

  aws_region    = "ap-south-1"
  alb_name      = "fbh-alb"
  internal      = false
  ip_address_type = "ipv4"

  # IMPORTANT: assume your VPC module exposes these outputs:
  # vpc_id and public_subnet_ids (change names to match your VPC module)
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  target_group_name = "fbh-tg"
  target_port       = 8080
  target_protocol   = "HTTP"
  target_type       = "instance" # or "ip"

  # If you want to auto attach instances, set list of instance IDs
  target_instance_ids = []

  certificate_arn = "" # set if you have cert and want HTTPS
  enable_http_redirect = true

  tags = {
    Project = "fbh-strapi"
    Env     = "dev"
  }

  # optionally create a target SG for your targets
  create_target_sg = true
  additional_target_ingress_rules = [
    {
      description = "Allow app traffic from anywhere"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
    }
  ]
}

resource "aws_amplify_app" "main" {
  name       = var.app_name
  repository = var.repository_url
  platform   = var.platform
 access_token = (var.repository_url != "" && var.amplify_access_token != "") ? var.amplify_access_token : null
  oauth_token  = (var.repository_url != "" && var.oauth_token  != "") ? var.oauth_token  : null

  # Optional framework
  dynamic "auto_branch_creation_config" {
    for_each = var.framework != "" ? [1] : []
    content {
      framework = var.framework
    }
  }

  environment_variables = var.environment_variables

  dynamic "custom_rule" {
    for_each = var.custom_rules
    content {
      source = custom_rule.value.source
      status = custom_rule.value.status
      target = custom_rule.value.target
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Branches
resource "aws_amplify_branch" "branches" {
  for_each = var.branches

  app_id            = aws_amplify_app.main.id
  branch_name       = each.key
  enable_auto_build = lookup(each.value, "enable_auto_build", true)

  environment_variables = lookup(each.value, "environment_variables", {})

  tags = {
    Project     = var.project_name
    Environment = var.environment
    Branch      = each.key
  }
}

# Webhook (optional)
resource "aws_amplify_webhook" "branch_webhook" {
  count       = var.create_webhook && var.webhook_branch_name != "" ? 1 : 0
  app_id      = aws_amplify_app.main.id
  branch_name = var.webhook_branch_name
}
# API Gateway Module
module "api_gateway" {
  source = "./modules/api-gateway"
  
  project_name = var.project_name
  environment  = var.environment
  
  # ALB integration
  alb_dns_name = module.alb.alb_dns_name
  
  # Stage configuration
  stage_name = var.api_gateway_stage_name
  
  # Custom domain (leave empty until you have certificate ARN)
  domain_name     = var.api_gateway_custom_domain
  certificate_arn = var.api_gateway_certificate_arn
  
  # Logging
  log_retention_days = var.api_gateway_log_retention
  enable_api_logs    = var.api_gateway_enable_logs
  
  depends_on = [module.alb]
}
# Domain association (optional)
locals {
  branch_prefix_list = flatten([
    for branch, prefixes in var.sub_domains : [
      for prefix in prefixes : {
        branch = branch
        prefix = prefix
      }
    ]
  ])
}

locals {
  branch_prefix_list_safe = length(local.branch_prefix_list) > 0 ? local.branch_prefix_list : [
    { branch = var.default_branch, prefix = "" }
  ]
}

resource "aws_amplify_domain_association" "domain_assoc" {
  count       = var.domain_name != "" ? 1 : 0
  app_id      = aws_amplify_app.main.id
  domain_name = var.domain_name

  dynamic "sub_domain" {
    for_each = local.branch_prefix_list_safe
    content {
      branch_name = sub_domain.value.branch
      prefix      = sub_domain.value.prefix
    }
  }
}

