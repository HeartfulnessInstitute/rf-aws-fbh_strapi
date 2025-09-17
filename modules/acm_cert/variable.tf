variable "domain_name" {
  type        = string
  description = "Primary domain name for the certificate (e.g. example.com)"
}

variable "subject_alternative_names" {
  type        = list(string)
  description = "Optional SANs for the certificate (e.g. [\"www.example.com\"])"
  default     = []
}

variable "route53_zone_id" {
  type        = string
  description = "Route53 Hosted Zone ID where DNS records will be created for validation"
}

variable "project_name" {
  type        = string
  description = "Project name (used only in tags / naming if needed)"
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment (dev/staging/prod) - used in tags"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to created resources"
  default     = {}
}
