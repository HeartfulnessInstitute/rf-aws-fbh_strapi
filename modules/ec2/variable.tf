variable "public_subnet_id" {
  type        = string
  description = "Public subnet id where EC2 will be launched"
}

variable "security_group_id" {
  type        = string
  description = "Security group id for EC2"
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name to attach to EC2"
  default     = ""
}

variable "key_pair_name" {
  type        = string
  description = "Key pair name for SSH access"
  default     = ""
}

variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "app_name" {
  type        = string
}

variable "rds_endpoint" {
  type        = string
  default     = ""
}

variable "db_name" {
  type        = string
  default     = ""
}

variable "db_username" {
  type        = string
  default     = ""
}

variable "db_password" {
  type        = string
  sensitive   = true
  default     = ""
}

variable "s3_bucket_name" {
  type        = string
  default     = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
