variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "EC2 security group ID"
  type        = string
}

variable "db_name" {
  description = <<-DESC
    Name of the initial database created inside the RDS instance.
    Must begin with a letter and contain only alphanumeric characters (a-z, A-Z, 0-9).
    Max length 63. Set to empty string ("") to skip creating an initial DB (e.g. when restoring from snapshot).
  DESC
  type    = string
  default = "fbhstrapi"

  validation {
    condition = (
      var.db_name == "" ||
      length(regexall("^[A-Za-z][A-Za-z0-9]{0,62}$", var.db_name)) == 1
    )
    error_message = "db_name must begin with a letter and contain only alphanumeric characters (max 63). Or set to \"\" to skip initial DB creation."
  }
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "allocated_storage" {
  description = "Allocated storage in GB"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}