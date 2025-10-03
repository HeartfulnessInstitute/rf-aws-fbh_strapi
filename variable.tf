
# Variables for root module
variable "aws_region" {
  description = "AWS region"
  type        = string
  
}

variable "environment" {
  description = "Environment name"
  type        = string

}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  
}
variable "db_name" {
  description = "Database username"
  type        = string
  
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
}
variable "domain_name" {
  description = "Custom domain name for CloudFront (optional)"
  type        = string
  default     = ""

}

variable "certificate_arn" {
  description = "SSL certificate ARN for custom domain (optional)"
  type        = string

}

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

variable "sub_domains" {
  type        = map(list(string))
  description = "Map of branch -> list of prefixes (e.g. { main = [\"www\", \"\"] })"
  default     = {}
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
  default     = "main"
}
variable "access_token" {
  description = "Personal access token for GitHub (classic PAT). Do NOT store in VCS; use env/CI secrets."
  type        = string
  sensitive   = true
  default     = ""
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
  default     = ""
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
  default     = ""
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