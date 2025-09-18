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

output "webhook_url" {
  description = "Webhook URL for triggering builds"
  value       = var.create_webhook ? aws_amplify_webhook.main[0].url : ""
  sensitive   = true
}