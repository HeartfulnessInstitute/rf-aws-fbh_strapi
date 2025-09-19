aws_region                 = "ap-south-1"
project_name               = "fbh-strapi"
app_name                   = "fbh-strapi-staging"

# Domain and SSL

key_pair_name           = "fbh_staging_strapi_key_pair"
bucket_name = "fbh_strapi"


# Global
environment  = "dev"

# Networking
vpc_cidr        = "10.0.0.0/16"
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
azs             = ["ap-south-1a", "ap-south-1b"]


# RDS
db_name              = "strapi_db"
db_username          = "admin"
db_password          = "SuperSecret123!"
db_instance_class    = "db.t3.micro"
db_engine            = "postgres"
db_engine_version    = "15.3"
db_allocated_storage = 20

# ACM / Route53
domain_name     = "dev.fbh.heartfulness.org"
route53_zone_id = "Z09281962GWDLD6759F5L"

# ALB
internal                   = false
enable_deletion_protection = false
load_balancer_name         = "strapi-dev-alb"
port                       = 80
target_group_protocol      = "HTTP"
target_type                = "instance"
target_group_port          = 80
health_check_path          = "/"
health_check_protocol      = "HTTP"
health_check_interval      = 30
health_check_timeout       = 5
health_check_healthy_threshold   = 3
health_check_unhealthy_threshold = 3
listener_port              = 443
listener_protocol          = "HTTPS"
# Amplify Configuration for Next.js
amplify_repository_url = "https://github.com/your-org/fbh-frontend"
amplify_framework      = "Next.js - SSG"
amplify_platform       = "WEB_COMPUTE"
amplify_domain_name    = "app.dev.fbh.heartfulness.org"

amplify_environment_variables = {
  NEXT_PUBLIC_STRAPI_URL    = "https://dev.fbh.heartfulness.org"
  NEXT_PUBLIC_API_URL       = "https://dev.fbh.heartfulness.org/api"
  NEXT_PUBLIC_HFN_CLIENT_ID = "e843d6b2-8f97-48bd-93c2-e7dcddc10448"
  NEXT_PUBLIC_ENV           = "dev"
}

amplify_branches = {
  main = {
    environment_variables = {
      NEXT_PUBLIC_BRANCH = "main"
    }
    framework                  = "Next.js - SSG"
    enable_auto_build         = true
    enable_pull_request_preview = true
  }
  develop = {
    environment_variables = {
      NEXT_PUBLIC_BRANCH = "develop"
    }
    framework                  = "Next.js - SSG"
    enable_auto_build         = true
    enable_pull_request_preview = false
  }
}

amplify_sub_domains = [
  {
    branch_name = "main"
    prefix      = ""
  },
  {
    branch_name = "develop"
    prefix      = "dev"
  }
]

amplify_create_webhook      = true
amplify_webhook_branch_name = "main"

amplify_build_spec = "version: 1\nfrontend:\n  phases:\n    preBuild:\n      commands:\n        - npm ci\n    build:\n      commands:\n        - npm run build\n        - npm run export\n  artifacts:\n    baseDirectory: out\n    files:\n      - '**/*'\n  cache:\n    paths:\n      - node_modules/**/*\n      - .next/cache/**/*"
# CloudFront Configuration
cloudfront_aliases = ["cdn.dev.fbh.heartfulness.org"]
# cloudfront_acm_certificate_arn = "arn:aws:acm:us-east-1:xxx:certificate/xxx" # Must be in us-east-1 for CloudFront