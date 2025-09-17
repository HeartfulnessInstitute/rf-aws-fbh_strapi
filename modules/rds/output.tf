output "endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.this.db_name
}

output "username" {
  description = "Master username"
  value       = aws_db_instance.this.username
}

output "port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "arn" {
  description = "ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}
