variable "aws_region" {
  description = "AWS region"
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

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID"
  type        = string
}

variable "key_pair_name" {
  description = "EC2 Key Pair name"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

# ALB Configuration Variables (from your existing pattern)
variable "internal" {
  description = "Whether the load balancer is internal"
  type        = bool
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
}

variable "load_balancer_name" {
  description = "Name of the load balancer"
  type        = string
}

variable "port" {
  description = "List of ports for the ALB"
  type        = list(number)
}

# Target Group Configuration
variable "target_group_protocol" {
  description = "Protocol for target group"
  type        = string
}

variable "target_type" {
  description = "Type of target (instance, ip, lambda)"
  type        = string
}

variable "target_group_port" {
  description = "Port for target group"
  type        = number
}

# Health Check Configuration
variable "health_check_path" {
  description = "Health check path"
  type        = string
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health checks before considering target healthy"
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health checks before considering target unhealthy"
  type        = number
}

# Listener Configuration
variable "listener_port" {
  description = "Port for the listener"
  type        = number
}

variable "listener_protocol" {
  description = "Protocol for the listener"
  type        = string
}
