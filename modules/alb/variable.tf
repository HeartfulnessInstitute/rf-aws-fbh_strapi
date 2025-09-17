# Networking
variable "vpc_id" {
  description = "VPC ID where ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID to attach to ALB"
  type        = string
}

# ACM
variable "certificate_arn" {
  description = "ARN of ACM certificate for HTTPS"
  type        = string
}

# EC2 attachment
variable "ec2_instance_id" {
  description = "EC2 instance ID to register in target group"
  type        = string
}

# Project metadata
variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

# ALB config
variable "internal" {
  description = "Whether the ALB is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on ALB"
  type        = bool
  default     = false
}

variable "load_balancer_name" {
  description = "Name of the ALB"
  type        = string
}

# Target Group config
variable "target_group_protocol" {
  description = "Protocol for target group (e.g., HTTP, HTTPS)"
  type        = string
  default     = "HTTP"
}

variable "target_group_port" {
  description = "Port for target group (e.g., 80)"
  type        = number
  default     = 80
}

variable "target_type" {
  description = "Target type for target group (instance, ip, lambda)"
  type        = string
  default     = "instance"
}

# Health check config
variable "health_check_path" {
  description = "Path for ALB health check"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Protocol for ALB health check"
  type        = string
  default     = "HTTP"
}

variable "health_check_interval" {
  description = "Interval between health checks (seconds)"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Timeout for health check response (seconds)"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of successful checks before healthy"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of failed checks before unhealthy"
  type        = number
  default     = 2
}

# Listener config
variable "listener_port" {
  description = "Port for HTTPS listener"
  type        = number
  default     = 443
}

variable "listener_protocol" {
  description = "Protocol for listener (HTTPS)"
  type        = string
  default     = "HTTPS"
}

# Route53
variable "domain_name" {
  description = "Domain name for Route53 record"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

# Listener rules (optional advanced routing)
variable "listener_rules" {
  description = "Map of listener rules with host/path conditions"
  type        = any
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
