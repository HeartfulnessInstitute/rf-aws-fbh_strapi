variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "v1"
}

variable "alb_dns_name" {
  description = "DNS name of the ALB to integrate with"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name for API Gateway (leave empty to use default)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain (must be in same region as API Gateway)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_api_logs" {
  description = "Enable detailed API Gateway logging"
  type        = bool
  default     = true
}