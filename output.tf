output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ec2_instance_id" {
  value = module.ec2.instance_id
}

output "ec2_public_ip" {
  value = module.ec2.public_ip
}

output "rds_endpoint" {
  value     = module.rds.db_endpoint
  sensitive = true
}
output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cloudfront.distribution_id
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cloudfront.distribution_domain_name
}

output "s3_bucket_name" {
  description = "S3 origin bucket name"
  value       = module.cloudfront.s3_bucket_id
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
output "app_id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.main.id
}

output "app_arn" {
  description = "Amplify App ARN"
  value       = aws_amplify_app.main.arn
}

output "default_domain" {
  description = "Default domain for the Amplify app"
  value       = aws_amplify_app.main.default_domain
}

output "app_url" {
  description = "URL of the Amplify app"
  value       = "https://${aws_amplify_app.main.default_domain}"
}

output "branch_urls" {
  description = "URLs for each branch"
  value = {
    for k, v in aws_amplify_branch.branches : k => "https://${k}.${aws_amplify_app.main.default_domain}"
  }
}

output "custom_domain_url" {
  description = "Custom domain URL (if configured)"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : ""
}

