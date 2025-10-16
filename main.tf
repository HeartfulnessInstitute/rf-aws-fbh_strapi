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
# -------------------------
# EC2 security group
# -------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Security group for EC2 app server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow SSH from admin CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ec2_allowed_ssh_cidrs
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-ec2-sg" })
}

# -------------------------
# Allow EC2 SG -> DB SG (security-group based ingress)
# -------------------------
resource "aws_security_group_rule" "allow_ec2_to_db" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id     # the DB SG created earlier
  source_security_group_id = aws_security_group.ec2_sg.id    # allow traffic from EC2 SG
  description              = "Allow EC2 app servers to reach the DB"
}

# -------------------------
# Normalize public subnet ids (works if module.vpc returns list or map)
# -------------------------
locals {
  ec2_public_subnet_ids = try(values(module.vpc.public_subnet_ids), module.vpc.public_subnet_ids)
}

# -------------------------
# EC2 instance
# -------------------------
resource "aws_instance" "app_server" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = local.ec2_public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.ec2_key_name

  associate_public_ip_address = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2"
  })
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
#Amplify#
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
