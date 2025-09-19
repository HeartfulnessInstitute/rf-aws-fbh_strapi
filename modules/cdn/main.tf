locals {
  s3_origin_id = "S3-${var.bucket_name}"
}

resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "OAI for ${var.bucket_name}"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.comment
  default_root_object = var.default_root_object
  aliases             = var.aliases
  price_class         = var.price_class

  origin {
    domain_name = var.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = var.min_ttl
    default_ttl            = var.default_ttl
    max_ttl                = var.max_ttl
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn != "" ? var.acm_certificate_arn : null
    ssl_support_method       = var.acm_certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version = var.acm_certificate_arn != "" ? "TLSv1.2_2021" : null
    cloudfront_default_certificate = var.acm_certificate_arn == ""
  }

  tags = var.tags
}

# Update S3 bucket policy to allow CloudFront access
data "aws_iam_policy_document" "cloudfront_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${var.bucket_arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.main.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_policy" {
  bucket = var.bucket_id
  policy = data.aws_iam_policy_document.cloudfront_s3_policy.json
}