# -------------------------
# Global / Common variables
# -------------------------
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name (used for tagging/naming)"
  type        = string
}

# -------------------------
# Networking / VPC
# -------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

# -------------------------
# EC2
# -------------------------
variable "key_pair_name" {
  description = "Existing AWS key pair name for EC2 access"
  type        = string
}

# -------------------------
# RDS
# -------------------------
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Master database username"
  type        = string
}

variable "db_password" {
  description = "Master database password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
}

variable "db_engine" {
  description = "Database engine (e.g. postgres, mysql)"
  type        = string
}

variable "db_engine_version" {
  description = "Database engine version"
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB"
  type        = number
}

# -------------------------
# ACM / Route53
# -------------------------
variable "domain_name" {
  description = "Domain name for ACM/Route53"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

# -------------------------
# ALB
# -------------------------
variable "internal" {
  description = "Whether the ALB is internal (true) or internet-facing (false)"
  type        = bool
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
}

variable "load_balancer_name" {
  description = "Name for the ALB"
  type        = string
}

variable "port" {
  description = "Port to use for the target group registration"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol for the target group (HTTP or HTTPS)"
  type        = string
}

variable "target_type" {
  description = "Target type for the target group (instance or ip)"
  type        = string
}

variable "target_group_port" {
  description = "Port the target group listens on"
  type        = number
}

variable "health_check_path" {
  description = "Path for ALB health checks"
  type        = string
}

variable "health_check_protocol" {
  description = "Protocol for ALB health checks"
  type        = string
}

variable "health_check_interval" {
  description = "Interval for ALB health checks (seconds)"
  type        = number
}

variable "health_check_timeout" {
  description = "Timeout for ALB health checks (seconds)"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successes to mark target healthy"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failures to mark target unhealthy"
  type        = number
}

variable "listener_port" {
  description = "Port for the ALB listener"
  type        = number
}

variable "listener_protocol" {
  description = "Protocol for the ALB listener"
  type        = string
}
variable "bucket_name" {
  type = string
}

variable "bucket_acl" {
  type    = string
  default = "private"
}

variable "force_destroy" {
  type    = bool
  default = false
}

variable "versioning" {
  type    = bool
  default = false
}

variable "website_enabled" {
  type    = bool
  default = false
}

variable "website_index_document" {
  type    = string
  default = "index.html"
}

variable "website_error_document" {
  type    = string
  default = "error.html"
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "aliases" {
  type    = list(string)
  default = []
}

variable "default_ttl" {
  type    = number
  default = 3600
}

variable "max_ttl" {
  type    = number
  default = 86400
}

variable "comment" {
  type    = string
  default = "CloudFront for S3"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "block_public_acls" {
  type    = bool
  default = true
}

variable "block_public_policy" {
  type    = bool
  default = true
}

variable "ignore_public_acls" {
  type    = bool
  default = true
}

variable "restrict_public_buckets" {
  type    = bool
  default = true
}
variable "amplify_repository_url" {
  description = "Git repository URL for Amplify app"
  type        = string
  default     = ""
}

variable "amplify_build_spec" {
  description = "Build specification for Amplify"
  type        = string
  default     = ""
}

variable "amplify_framework" {
  description = "Frontend framework"
  type        = string
  default     = "Next.js - SSG"
}

variable "amplify_platform" {
  description = "Amplify platform type"
  type        = string
  default     = "WEB_COMPUTE"
}

variable "amplify_environment_variables" {
  description = "Environment variables for Amplify app"
  type        = map(string)
  default     = {}
}

variable "amplify_branches" {
  description = "Amplify branches configuration"
  type = map(object({
    environment_variables       = map(string)
    framework                  = string
    enable_auto_build         = bool
    enable_pull_request_preview = bool
  }))
  default = {}
}

variable "amplify_domain_name" {
  description = "Custom domain for Amplify app"
  type        = string
  default     = ""
}

variable "amplify_sub_domains" {
  description = "Sub domains for Amplify"
  type = list(object({
    branch_name = string
    prefix      = string
  }))
  default = []
}

variable "amplify_custom_rules" {
  description = "Custom rules for Amplify routing (Next.js specific)"
  type = list(object({
    source = string
    status = string
    target = string
  }))
  default = [
    {
      source = "/_next/static/*"
      status = "200"
      target = "/_next/static/*"
    },
    {
      source = "/api/*"
      status = "200"
      target = "/api/*"
    },
    {
      source = "/<*>"
      status = "404-200"
      target = "/index.html"
    }
  ]
}

variable "amplify_create_webhook" {
  description = "Create webhook for Amplify"
  type        = bool
  default     = false
}

variable "amplify_webhook_branch_name" {
  description = "Branch name for Amplify webhook"
  type        = string
  default     = "main"
}
variable "cloudfront_acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront custom domain"
  type        = string
  default     = ""
}

variable "cloudfront_aliases" {
  description = "Custom domain aliases for CloudFront"
  type        = list(string)
  default     = []
}