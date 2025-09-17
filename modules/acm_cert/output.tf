output "certificate_arn" {
  description = "ARN of the issued ACM certificate"
  value       = aws_acm_certificate.this.arn
}

output "certificate_domain" {
  description = "Primary domain name on the certificate"
  value       = aws_acm_certificate.this.domain_name
}

output "certificate_status" {
  description = "Status of the certificate (PENDING_VALIDATION/ISSUED/etc.)"
  value       = aws_acm_certificate.this.status
}

output "validation_record_fqdns" {
  description = "FQDNs of Route53 records created for validation"
  value       = [for r in aws_route53_record.validation : r.fqdn]
}
