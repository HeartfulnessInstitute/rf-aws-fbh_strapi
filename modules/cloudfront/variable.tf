
# modules/cloudfront/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
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
  default     = ""
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "enable_logging" {
  description = "Enable CloudFront access logging"
  type        = bool
  default     = true
}

variable "default_root_object" {
  description = "Default root object"
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