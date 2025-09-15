aws_region                 = "ap-south-1"
project_name               = "fbh-strapi"
environment                = "staging"
app_name                   = "fbh-strapi-staging"

# ALB Settings
internal                   = false
enable_deletion_protection = false
load_balancer_name         = "FBH-Strapi-ALB-Staging"
port                       = [80, 443]

# Target Group Settings
target_group_protocol      = "HTTP"
target_type               = "instance"
target_group_port         = 1337  # Strapi port

# Health Checks
health_check_path         = "/"
health_check_protocol     = "HTTP"
health_check_interval     = 30
health_check_timeout      = 5
health_check_healthy_threshold   = 2
health_check_unhealthy_threshold = 3

# Domain and SSL
domain_name               = "domain name "
route53_zone_id          = "Z123456ABCDEFG"

# Database
db_password              = "secure-password"
key_pair_name           = "fbh_staging_strapi_key_pair"