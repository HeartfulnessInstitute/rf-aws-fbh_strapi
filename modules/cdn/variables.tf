variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "bucket_id" {
  description = "ID of the S3 bucket"
  type        = string
}

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  type        = string
}

variable "bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = ""
}

variable "aliases" {
  description = "Custom domain names for CloudFront"
  type        = list(string)
  default     = []
}

variable "comment" {
  description = "Comment for CloudFront distribution"
  type        = string
  default     = "CDN for S3 bucket"
}

variable "default_root_object" {
  description = "Default root object"
  type        = string
  default     = "index.html"
}

variable "price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "min_ttl" {
  description = "Minimum TTL"
  type        = number
  default     = 0
}

variable "default_ttl" {
  description = "Default TTL"
  type        = number
  default     = 3600
}

variable "max_ttl" {
  description = "Maximum TTL"
  type        = number
  default     = 86400
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}