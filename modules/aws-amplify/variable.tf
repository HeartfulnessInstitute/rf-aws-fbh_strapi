variable "app_name" {
  description = "Name of the Amplify app"
  type        = string
}

variable "repository_url" {
  description = "URL of the Git repository"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "build_spec" {
  description = "Build specification for Amplify"
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for the Amplify app"
  type        = map(string)
  default     = {}
}

variable "custom_rules" {
  description = "Custom rules for routing"
  type = list(object({
    source = string
    status = string
    target = string
  }))
  default = []
}

variable "enable_auto_branch_creation" {
  description = "Enable automatic branch creation"
  type        = bool
  default     = false
}

variable "auto_branch_enable_auto_build" {
  description = "Enable auto build for auto-created branches"
  type        = bool
  default     = false
}

variable "auto_branch_environment_variables" {
  description = "Environment variables for auto-created branches"
  type        = map(string)
  default     = {}
}

variable "framework" {
  description = "Framework for the application"
  type        = string
  default     = "Next.js - SSG"
}

variable "enable_pull_request_preview" {
  description = "Enable pull request previews"
  type        = bool
  default     = false
}

variable "platform" {
  description = "Platform type (WEB or WEB_COMPUTE)"
  type        = string
  default     = "WEB_COMPUTE"
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

variable "branches" {
  description = "Branches to create"
  type = map(object({
    environment_variables       = map(string)
    framework                  = string
    enable_auto_build         = bool
    enable_pull_request_preview = bool
  }))
  default = {}
}

variable "domain_name" {
  description = "Custom domain name for Amplify app"
  type        = string
  default     = ""
}

variable "sub_domains" {
  description = "Sub domains configuration"
  type = list(object({
    branch_name = string
    prefix      = string
  }))
  default = []
}

variable "create_webhook" {
  description = "Create webhook for triggering builds"
  type        = bool
  default     = false
}

variable "webhook_branch_name" {
  description = "Branch name for webhook"
  type        = string
  default     = "main"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}