output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.main.id
}

output "rest_api_name" {
  description = "Name of the REST API"
  value       = aws_api_gateway_rest_api.main.name
}

output "rest_api_root_resource_id" {
  description = "Root resource ID of the REST API"
  value       = aws_api_gateway_rest_api.main.root_resource_id
}

output "stage_name" {
  description = "Stage name"
  value       = aws_api_gateway_stage.main.stage_name
}

output "invoke_url" {
  description = "Default invoke URL (without custom domain)"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "custom_domain_name" {
  description = "Custom domain name (if configured)"
  value       = var.domain_name != "" && var.certificate_arn != "" ? aws_api_gateway_domain_name.main[0].domain_name : ""
}

output "custom_domain_cloudfront_domain_name" {
  description = "CloudFront domain name for custom domain (use this in Route53/DNS)"
  value       = var.domain_name != "" && var.certificate_arn != "" ? aws_api_gateway_domain_name.main[0].cloudfront_domain_name : ""
}

output "custom_domain_cloudfront_zone_id" {
  description = "CloudFront zone ID for custom domain (use this in Route53)"
  value       = var.domain_name != "" && var.certificate_arn != "" ? aws_api_gateway_domain_name.main[0].cloudfront_zone_id : ""
}

output "api_endpoint" {
  description = "Full API endpoint URL (custom domain if available, otherwise default)"
  value       = var.domain_name != "" && var.certificate_arn != "" ? "https://${var.domain_name}" : aws_api_gateway_stage.main.invoke_url
}