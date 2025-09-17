# ALB outputs (from ./modules/alb)
output "alb_dns_name" {
  description = "ALB DNS name"
  value       = try(module.alb.alb_dns_name, "")
}

output "alb_zone_id" {
  description = "ALB hosted zone ID"
  value       = try(module.alb.alb_zone_id, "")
}

output "alb_arn" {
  description = "ALB ARN"
  value       = try(module.alb.alb_arn, "")
}

# EC2 outputs (from ./modules/ec2)
output "ec2_instance_id" {
  description = "EC2 instance id"
  value       = try(module.ec2.instance_id, "")
}

output "ec2_public_ip" {
  description = "EC2 public IP (if assigned)"
  value       = try(module.ec2.instance_public_ip, "")
}

output "ec2_private_ip" {
  description = "EC2 private IP"
  value       = try(module.ec2.instance_private_ip, "")
}

# S3 outputs (from ./modules/s3)
output "s3_bucket_name" {
  description = "S3 bucket name created for the app"
  value       = try(module.s3.bucket_name, "")
}

# ACM outputs
output "acm_certificate_arn" {
  description = "ACM certificate ARN"
  value       = try(module.acm_cert.certificate_arn, "")
}

# VPC / Networking outputs (from git vpc module)
output "vpc_id" {
  description = "VPC ID"
  value       = try(module.vpc.vpc_id, "")
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = try(module.vpc.public_subnets, try(module.vpc.public_subnet_ids, []))
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = try(module.vpc.private_subnets, try(module.vpc.private_subnet_ids, []))
}

# Security groups (from ./modules/security_groups)
output "ec2_security_group_id" {
  description = "EC2 security group id"
  value       = try(module.security_groups.ec2_security_group_id, "")
}

output "alb_security_group_id" {
  description = "ALB security group id"
  value       = try(module.security_groups.alb_security_group_id, "")
}

output "rds_security_group_id" {
  description = "RDS security group id"
  value       = try(module.security_groups.rds_security_group_id, "")
}
