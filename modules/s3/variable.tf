variable "project_name" {
  type        = string
  description = "Project name (used in resource names)"
}

variable "environment" {
  type        = string
  description = "Environment (dev/staging/prod)"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "tags" {
  type        = map(string)
  description = "Common tags map"
  default     = {}
}
