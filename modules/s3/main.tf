resource "random_pet" "bucket_suffix" {
  length = 2
}

resource "aws_s3_bucket" "this" {
  bucket = lower("${var.project_name}-${var.environment}-${var.app_name}-${random_pet.bucket_suffix.id}")

  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "expire-objects"
    enabled = true

    expiration {
      days = 365
    }

    noncurrent_version_expiration {
      days = 90
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-${var.app_name}-bucket"
  })
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Role for EC2 (assume-role for ec2 service)
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-${var.app_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM policy granting access to the bucket (narrow scope)
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowBucketAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.this.arn
    ]
  }

  statement {
    sid    = "AllowObjectActions"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]

    resources = [
      "${aws_s3_bucket.this.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "bucket_policy" {
  name   = "${var.project_name}-${var.environment}-${var.app_name}-s3-policy"
  policy = data.aws_iam_policy_document.bucket_policy.json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-${var.app_name}-instance-profile"
  role = aws_iam_role.ec2_role.name
  tags = var.tags
}
