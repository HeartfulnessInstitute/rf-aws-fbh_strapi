# modules/cloudfront/outputs.tf
output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.main.arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  value       = aws_cloudfront_distribution.main.hosted_zone_id
}

output "s3_bucket_id" {
  description = "S3 origin bucket ID"
  value       = aws_s3_bucket.origin.id
}

output "s3_bucket_arn" {
  description = "S3 origin bucket ARN"
  value       = aws_s3_bucket.origin.arn
}

output "s3_bucket_domain_name" {
  description = "S3 origin bucket domain name"
  value       = aws_s3_bucket.origin.bucket_domain_name
}

output "logs_bucket_id" {
  description = "S3 logs bucket ID (if logging enabled)"
  value       = var.enable_logging ? aws_s3_bucket.logs[0].id : null
}

output "origin_access_control_id" {
  description = "CloudFront Origin Access Control ID"
  value       = aws_cloudfront_origin_access_control.main.id
}