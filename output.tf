######################################
# VPC Outputs
######################################

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "List of created public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of created private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "debug_vpc_private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}



# RDS Instance Outputs
output "rds_instance_id" {
  description = "The unique identifier for the RDS instance"
  value       = module.rds.db_instance_id
}

output "rds_instance_arn" {
  description = "ARN of the RDS instance"
  value       = module.rds.db_instance_arn
}

output "rds_endpoint" {
  description = "Connection endpoint (hostname) of the RDS instance"
  value       = module.rds.endpoint
}

output "rds_address" {
  description = "DNS address of the RDS instance"
  value       = module.rds.address
}

output "rds_port" {
  description = "Port number the RDS instance is listening on"
  value       = module.rds.port
}

output "rds_subnet_group_name" {
  description = "Name of the DB subnet group used by the RDS instance"
  value       = module.rds.subnet_group_name
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

#cloudfront#
# read outputs from the cloudfront module (safe: uses try() so plan doesn't fail if module missing)
output "distribution_id" {
  description = "CloudFront distribution id"
  value       = try(module.cloudfront.distribution_id, null)
}

output "distribution_arn" {
  description = "CloudFront distribution arn"
  value       = try(module.cloudfront.distribution_arn, null)
}

output "distribution_domain_name" {
  description = "CloudFront domain name"
  value       = try(module.cloudfront.distribution_domain_name, null)
}

output "distribution_hosted_zone_id" {
  description = "CloudFront hosted zone id"
  value       = try(module.cloudfront.distribution_hosted_zone_id, null)
}

output "s3_bucket_id" {
  description = "Origin S3 bucket id (from module)"
  value       = try(module.cloudfront.origin_bucket_id, null)
}

output "s3_bucket_arn" {
  description = "Origin S3 bucket arn (from module)"
  value       = try(module.cloudfront.origin_bucket_arn, null)
}

output "s3_bucket_domain_name" {
  description = "Origin S3 bucket domain name (from module)"
  value       = try(module.cloudfront.origin_bucket_domain_name, null)
}

output "logs_bucket_id" {
  description = "Logs bucket id (if logging enabled)"
  value       = try(module.cloudfront.logs_bucket_id, null)
}

output "origin_access_control_id" {
  description = "Origin access control id (if created)"
  value       = try(module.cloudfront.origin_access_control_id, null)
}


# ALB outputs (from the alb module)
output "alb_arn" {
  value       = try(module.alb.alb_arn, "")
  description = "ARN of the ALB created by the alb module"
}

output "alb_dns_name" {
  value       = try(module.alb.alb_dns_name, "")
  description = "DNS name of the ALB"
}

output "alb_security_group_id" {
  value       = try(module.alb.alb_security_group_id, "")
  description = "Security group id of the ALB"
}

output "target_group_arn" {
  value       = try(module.alb.target_group_arn, "")
  description = "Target group ARN created by the ALB module"
}

#Amplify#
output "amplify_app_id" {
  description = "Amplify App ID"
  value       = module.amplify_app.app_id
}

output "amplify_app_arn" {
  description = "Amplify App ARN"
  value       = module.amplify_app.app_arn
}

output "amplify_default_domain" {
  description = "Default Amplify domain"
  value       = module.amplify_app.default_domain
}

output "amplify_app_url" {
  description = "Amplify application URL"
  value       = module.amplify_app.app_url
}

output "amplify_custom_domain" {
  description = "Custom domain (if configured)"
  value       = module.amplify_app.custom_domain
}

output "amplify_iam_role_arn" {
  description = "IAM role ARN for Amplify service"
  value       = module.amplify_app.iam_role_arn
}
# API Gateway Outputs
output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = module.api_gateway.rest_api_id
}

output "api_gateway_invoke_url" {
  description = "Default API Gateway invoke URL"
  value       = module.api_gateway.invoke_url
}

output "api_gateway_endpoint" {
  description = "API Gateway endpoint (custom domain if configured, otherwise default)"
  value       = module.api_gateway.api_endpoint
  sensitive   = true
}

output "api_gateway_custom_domain" {
  description = "API Gateway custom domain name"
  value       = module.api_gateway.custom_domain_name
  sensitive   = true
}
output "api_gateway_custom_domain_target" {
  description = "Target domain for DNS record (use this in Route53)"
  value       = module.api_gateway.custom_domain_cloudfront_domain_name
  sensitive   = true
}
