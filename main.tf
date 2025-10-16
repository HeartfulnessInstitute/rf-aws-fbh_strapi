# 1) VPC module (creates subnets). This module returns private_subnet_ids as an object/map.
module "vpc" {
  source             = "git::https://github.com/HeartfulnessInstitute/tf-aws-vpc.git?ref=v1.0.0"
  name_prefix        = var.name_prefix
  vpc_cidr           = var.vpc_cidr
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  enable_nat_gateway = var.enable_nat_gateway
  tags               = var.tags
}

# 2) DB security group (allow access from your app SG or CIDR)
resource "aws_security_group" "db_sg" {
  name        = "${var.name_prefix}-db-sg"
  description = "Allow DB access"
  vpc_id      = module.vpc.vpc_id

  # example allowing app security group or CIDR (adjust as needed)
  ingress {
    description      = "Postgres from app"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    # replace with your app SG id or trusted CIDR
    cidr_blocks      = var.db_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-db-sg" })
}

# 3) If your VPC module returns private_subnet_ids as a map/object, convert to list using values()
locals {
  rds_subnet_ids = try(values(module.vpc.private_subnet_ids), module.vpc.private_subnet_ids)
}

# 4) RDS module: pass the subnet ids from the newly-created VPC
module "rds" {
  source = "git::https://github.com/HeartfulnessInstitute/tf-aws-rds.git?ref=sub_branch"

  name              = var.db_identifier
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage

  # pass the normalized list
  db_subnet_ids     = local.rds_subnet_ids

  security_group_ids = [aws_security_group.db_sg.id]
  username           = var.db_username
  password           = var.db_password
  storage_type = var.storage_type
  multi_az = "false"
  publicly_accessible ="false"

  tags = merge(var.tags, { Project = "heartfulness" })
}
# CloudFront Module
module "cloudfront" {
  source = "git::https://github.com/HeartfulnessInstitute/tf-aws-cloudfront.git?ref=feature"
  
  # required/expected inputs (adjust as needed per your module's variables)
  environment            = var.environment
  project_name           = var.project_name
  domain_name            = var.domain_name
  certificate_arn        = var.certificate_arn
  price_class            = var.price_class
  enable_logging         = var.enable_logging
  default_root_object    = var.default_root_object
  enable_ipv6            = var.enable_ipv6
  minimum_protocol_version = var.minimum_protocol_version

  # caching controls
  allowed_methods        = var.allowed_methods
  cached_methods         = var.cached_methods
  compress               = var.compress
  default_ttl            = var.default_ttl
  max_ttl                = var.max_ttl
  min_ttl                = var.min_ttl
}
module "amplify_app" {
  source = "git::https://github.com/HeartfulnessInstitute/tf-aws-amplify.git?ref=feature"

  app_name        = var.app_name
  app_description = "Amplify application deployed with Terraform"
  repository_url  = var.repository_url
  github_token    = ""   #amplify github token
  platform        = "WEB"
  environment     = var.environment
  main_branch_name = "main"
  framework       = var.framework
  branch_stage    = var.branch_stage

  enable_auto_branch_creation = false
  enable_branch_auto_build    = true
  enable_basic_auth           = false

  environment_variables = {
    REACT_APP_API_URL = var.react_app_api_url
    REACT_APP_ENV     = var.environment
  }

  branch_environment_variables = {}

  domain_name   = var.domain_name
  domain_prefix = var.domain_prefix

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
# API Gateway Module
module "api_gateway" {
  source = "git::https://github.com/HeartfulnessInstitute/tf-aws-apigateway.git?ref=feature"
  
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

# Domain association 
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

#Loadbalancer#
module "alb" {
  source = "git::https://github.com/HeartfulnessInstitute/tf-aws-alb.git?ref=sub_branch"

  aws_region    = var.aws_region
  alb_name      = var.alb_name
  internal      = false
  ip_address_type = "ipv4"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids

  target_group_name = var.target_group_name
  target_port       = 8080
  target_protocol   = "HTTP"
  target_type       = "instance" # or "ip"

  # If you want to auto attach instances, set list of instance IDs
  target_instance_ids = []

  certificate_arn = "arn:aws:acm:ap-south-1:502390415551:certificate/912617f2-6890-4d84-a093-7e2e591b5e7b" # set if you have cert and want HTTPS
  enable_http_redirect = true

  tags = {
    Project = var.project_name
    Env     = var.environment
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
