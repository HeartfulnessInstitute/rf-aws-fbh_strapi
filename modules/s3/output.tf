output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "role_name" {
  value = aws_iam_role.ec2_role.name
}

output "role_arn" {
  value = aws_iam_role.ec2_role.arn
}
