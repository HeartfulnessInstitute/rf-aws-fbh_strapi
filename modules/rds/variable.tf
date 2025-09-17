variable "vpc_id" {
  type        = string
  description = "VPC ID where RDS will be launched"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for RDS subnet group"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for RDS instance"
}

variable "db_password" {
  type        = string
  sensitive   = true
  description = "Master DB password"
}

variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "app_name" {
  type        = string
  default     = "app"
}

variable "tags" {
  type    = map(string)
  default = {}
}

# DB-specific settings
variable "engine" {
  type        = string
  description = "Database engine (postgres, mysql, etc.)"
  default     = "postgres"
}

variable "engine_version" {
  type        = string
  description = "Database engine version"
  default     = "15.3"
}

variable "instance_class" {
  type        = string
  description = "RDS instance type"
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  type        = number
  description = "Initial storage in GB"
  default     = 20
}

variable "max_allocated_storage" {
  type        = number
  description = "Maximum storage in GB (auto-scaling)"
  default     = 100
}

variable "db_name" {
  type        = string
  description = "Database name to create"
  default     = "strapi_db"
}

variable "username" {
  type        = string
  description = "Master DB username"
  default     = "admin"
}

variable "port" {
  type        = number
  description = "Database port"
  default     = 5432
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Whether to skip creating a final snapshot on DB deletion"
  default     = true
}

variable "deletion_protection" {
  type        = bool
  description = "Protect DB from accidental deletion"
  default     = false
}

variable "backup_retention_period" {
  type        = number
  description = "Backup retention period in days"
  default     = 7
}

variable "multi_az" {
  type        = bool
  description = "Enable Multi-AZ deployment"
  default     = false
}
