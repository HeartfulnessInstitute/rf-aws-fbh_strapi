variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable or disable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}


variable "db_identifier" {
  description = "Identifier for the RDS instance"
  type        = string
}

variable "db_engine" {
  description = "Database engine type (e.g., postgres, mysql)"
  type        = string
}

variable "db_engine_version" {
  description = "Version of the database engine"
  type        = string
  default     = "13"
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string

}

variable "db_allocated_storage" {
  description = "Allocated storage size (in GB)"
  type        = number
}
variable "storage_type" {
  description = "Storage type for RDS (gp2, gp3, io1, etc.)"
  type        = string
}


variable "db_username" {
  description = "Master username for the RDS instance"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS instance"
  type        = string
  sensitive   = true
}

variable "db_allowed_cidrs" {
  description = "List of CIDR blocks allowed to access the RDS instance"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}
#EC2#
variable "ec2_ami" {
  description = "AMI ID for the EC2 instance (e.g., Amazon Linux 2 AMI)"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ec2_key_name" {
  description = "SSH key pair name to attach to EC2"
  type        = string
}

variable "ec2_allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH into EC2 (admin/public IPs)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "db_port" {
  description = "Database port (used when creating SG rule allowing EC2 -> DB)"
  type        = number
}


# cloudfront#

variable "certificate_arn" {
  description = "SSL/TLS certificate ARN for custom domain (optional)"
  type        = string
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "price_class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "enable_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = false
}

variable "default_root_object" {
  description = "Default root object for CloudFront (e.g., index.html)"
  type        = string
  default     = "index.html"
}

variable "enable_ipv6" {
  description = "Enable IPv6 for CloudFront"
  type        = bool
  default     = true
}

variable "minimum_protocol_version" {
  description = "Minimum TLS protocol version"
  type        = string
  default     = "TLSv1.2_2021"
}

variable "allowed_methods" {
  description = "HTTP methods allowed by CloudFront"
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
}

variable "cached_methods" {
  description = "HTTP methods that CloudFront caches responses for"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "compress" {
  description = "Enable CloudFront compression"
  type        = bool
  default     = true
}

variable "default_ttl" {
  description = "Default TTL for cached objects (seconds)"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL for cached objects (seconds)"
  type        = number
  default     = 86400
}

variable "min_ttl" {
  description = "Minimum TTL for cached objects (seconds)"
  type        = number
  default     = 0
}
# AWS / general
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

variable "aws_profile" {
  description = "Optional AWS CLI profile name (leave blank to use default credentials)"
  type        = string
  default     = ""
}

#ALB#
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

variable "target_group_name" {
  description = "Name of the Target Group"
  type        = string
}

# Amplify / app inputs
variable "build_spec" {
  type        = string
  description = "Amplify build spec YAML content"
  default     = ""
}

variable "framework" {
  type        = string
  description = "Amplify frontend framework (optional)"
  default     = ""
}

variable "platform" {
  type        = string
  description = "Amplify platform (e.g. WEB)"
  default     = "WEB"
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for Amplify app"
  default     = {}
}

variable "branches" {
  type = map(object({
    enable_auto_build     = optional(bool, true)
    environment_variables = optional(map(string), {})
  }))
  description = "Map of branch_name => config"
  default     = {}
}

variable "domain_name" {
  description = "Domain name for domain association (root domain). Empty string disables domain creation."
  type        = string
  default     = ""

  validation {
    condition     = var.domain_name == "" || length(var.sub_domains) > 0 || length(keys(var.branches)) > 0
    error_message = "When 'domain_name' is set you must provide either at least one item in 'sub_domains' OR at least one branch in 'branches' (so Amplify has a branch to attach the root sub_domain)."
  }
}

variable "sub_domains" {
  description = "List of subdomain objects for domain association. Example: [{ branch_name = \"main\", prefix = \"www\" }]"
  type = list(object({
    branch_name = string
    prefix      = string
  }))
  default = []
}

variable "custom_rules" {
  type        = list(object({
    source = string
    status = string
    target = string
  }))
  description = "Custom rewrite/redirect rules"
  default     = []
}

variable "create_webhook" {
  type        = bool
  description = "Whether to create a webhook"
  default     = false
}

variable "webhook_branch_name" {
  type        = string
  description = "Branch name for webhook"
  default     = ""
}
variable "app_name" {
  type        = string
  description = "Amplify app name"
}

variable "repository_url" {
  type        = string
  description = "Repository URL for Amplify app"
}

variable "default_branch" {
  description = "Default branch to associate with the domain when no subdomains are given"
  type        = string

}
variable "access_token" {
  description = "Personal access token for GitHub (classic PAT). Do NOT store in VCS; use env/CI secrets."
  type        = string
  sensitive   = true
}

variable "oauth_token" {
  description = "OAuth token for other providers (Bitbucket/GitLab). Sensitive."
  type        = string
  sensitive   = true
  default     = ""
}
variable "amplify_access_token" {
  description = "GitHub personal access token for Amplify"
  type        = string
  sensitive   = true
}


# API Gateway Variables
variable "api_gateway_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "api_gateway_custom_domain" {
  description = "Custom domain for API Gateway"
  type        = string
}

variable "api_gateway_certificate_arn" {
  description = "ACM certificate ARN for API Gateway custom domain"
  type        = string
  default     = ""
  sensitive   = true
}

variable "api_gateway_log_retention" {
  description = "CloudWatch log retention for API Gateway in days"
  type        = number
  default     = 7
}

variable "api_gateway_enable_logs" {
  description = "Enable detailed API Gateway logging"
  type        = bool
  default     = true
}
