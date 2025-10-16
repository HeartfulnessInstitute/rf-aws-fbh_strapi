aws_region = "ap-south-1"
name_prefix        = "fbh"
vpc_cidr           = "10.0.0.0/16"
public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets    = ["10.0.10.0/24", "10.0.11.0/24"]
enable_nat_gateway = false
#DataBase#
db_identifier           = "fbh-db-dev"
db_engine               = "mysql"
db_engine_version       = "8.0"
db_instance_class       = "db.t3.micro"
db_username             = "admin"
db_password             = "SecurePassword123"
db_port ="5432"
db_allocated_storage    = 20
storage_type = "gp3"
tags = {
  Project     = "fbh-strapi"
  Environment = "dev"
  Owner       = "heartfulness"
}
#Ec2#
project_name   = "fbh-strapi"
environment = "dev"
ec2_key_name = "fbh_strapi"
ec2_instance_type ="t3.micro"
ec2_ami ="ami-0f9708d1cd2cfee41"

#alb#
alb_name ="fbh-alb"
target_group_name = "fbh-tg"
target_port = "80"
#cloudfront#

# CloudFront Configuration
#cloudfront_aliases = ["cdn.fbh.dev.heartfulness.org"]
# cloudfront_acm_certificate_arn = "arn:aws:acm:us-east-1:xxx:certificate/xxx" # Must be in us-east-1 for CloudFront
default_root_object ="index.html"
#api_gateway_stage_name     = "v1"
#api_name        = "fbh"
#api_gateway_custom_domain  = "fbh.dev.heartfulness.org"
#region                      = "ap-south-1"
#endpoint_type               = "REGIONAL"              # or "EDGE"
#stage_name                  = "dev"
#custom_domain_name          = "fbh.dev.heartfulness.org"
#certificate_arn             = "arn:aws:acm:ap-south-1:502390415551:certificate/912617f2-6890-4d84-a093-7e2e591b5e7b"   # Mumbai cert
#certificate_arn_us_east_1  = "arn:aws:acm:us-east-1:502390415551:certificate/d6f45361-48f1-4256-aea6-cae4c8804796"   # N. Virginia cert for EDGE
# Amplify Configuration for Next.js
repository_url = "https://github.com/bugcurefrontend/fbh-frontend"
app_name = "fbh"
webhook_branch_name ="main"
default_branch ="main"

platform       = "WEB_COMPUTE"
 framework      = "React"
 amplify_access_token = ""

 environment_variables = {
   REACT_APP_API_URL = "https://fbh.dev.heartfulness.org"
   REACT_APP_ENV     = "production"
}

branches = {
  main = {
    branch_name = "main"
    framework   = "React"      # Add this line
    stage       = "DEVELOPMENT"
    enable_auto_build = true
    enable_pull_request_preview = false
  }
  develop = {
    branch_name = "develop"
    framework   = "React"      # Add this line
    stage       = "DEVELOPMENT"
    enable_auto_build = true
    enable_pull_request_preview = true
  }
}

 domain_name = "fbh.dev.heartfulness.org"
create_webhook      = true
access_token =""
certificate_arn = "arn:aws:acm:us-east-1:502390415551:certificate/d6f45361-48f1-4256-aea6-cae4c8804796"

#api-gateway#
api_gateway_custom_domain ="fbh.dev.heartfulness.org"
# API Gateway Configuration
api_gateway_stage_name      = "v1"

api_gateway_certificate_arn = "arn:aws:acm:ap-south-1:502390415551:certificate/912617f2-6890-4d84-a093-7e2e591b5e7b"
api_gateway_log_retention   = 7
api_gateway_enable_logs     = false
