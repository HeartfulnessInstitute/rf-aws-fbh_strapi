
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