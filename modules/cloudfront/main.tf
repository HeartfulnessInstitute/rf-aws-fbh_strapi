resource "aws_s3_bucket" "origin" {
  bucket = "${var.project_name}-${var.environment}-cloudfront-origin"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudfront-origin"
    Environment = var.environment
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "origin" {
  bucket = aws_s3_bucket.origin.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "origin" {
  bucket = aws_s3_bucket.origin.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "origin" {
  bucket = aws_s3_bucket.origin.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket for CloudFront Logs (conditional)
resource "aws_s3_bucket" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = "${var.project_name}-${var.environment}-cloudfront-logs"

  tags = {
    Name        = "${var.project_name}-${var.environment}-cloudfront-logs"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "OAC for ${var.project_name} ${var.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = aws_s3_bucket.origin.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.origin.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
  }

  enabled             = true
  is_ipv6_enabled     = var.enable_ipv6
  default_root_object = var.default_root_object
  price_class         = var.price_class

  # Custom domain configuration (optional)
  aliases = var.domain_name != "" ? [var.domain_name] : []

  default_cache_behavior {
    allowed_methods            = var.allowed_methods
    cached_methods             = var.cached_methods
    target_origin_id           = "S3-${aws_s3_bucket.origin.bucket}"
    compress                   = var.compress
    viewer_protocol_policy     = "redirect-to-https"
    cache_policy_id           = aws_cloudfront_cache_policy.main.id
    origin_request_policy_id  = aws_cloudfront_origin_request_policy.main.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.main.id
  }

  # Custom error pages
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  # Geographic restrictions
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # SSL/TLS Configuration
  viewer_certificate {
    # Use custom certificate if provided
    acm_certificate_arn      = var.certificate_arn != "" ? var.certificate_arn : null
    ssl_support_method       = var.certificate_arn != "" ? "sni-only" : null
    minimum_protocol_version = var.certificate_arn != "" ? var.minimum_protocol_version : null
    
    # Use default CloudFront certificate if no custom certificate
    cloudfront_default_certificate = var.certificate_arn == "" ? true : null
  }

  # Logging configuration (conditional)
  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = aws_s3_bucket.logs[0].bucket_domain_name
      prefix          = "cloudfront-logs/"
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-distribution"
    Environment = var.environment
  }

  depends_on = [
    aws_cloudfront_origin_access_control.main
  ]
}

# Cache Policy
resource "aws_cloudfront_cache_policy" "main" {
  name        = "${var.project_name}-${var.environment}-cache-policy"
  comment     = "Cache policy for ${var.project_name} ${var.environment}"
  default_ttl = var.default_ttl
  max_ttl     = var.max_ttl
  min_ttl     = var.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    query_strings_config {
      query_string_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    cookies_config {
      cookie_behavior = "none"
    }
  }
}

# Origin Request Policy
resource "aws_cloudfront_origin_request_policy" "main" {
  name    = "${var.project_name}-${var.environment}-origin-request-policy"
  comment = "Origin request policy for ${var.project_name} ${var.environment}"

  query_strings_config {
    query_string_behavior = "none"
  }

  headers_config {
    header_behavior = "whitelist"
    headers {
      items = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
    }
  }

  cookies_config {
    cookie_behavior = "none"
  }
}

# Response Headers Policy
resource "aws_cloudfront_response_headers_policy" "main" {
  name    = "${var.project_name}-${var.environment}-response-headers-policy"
  comment = "Response headers policy for ${var.project_name} ${var.environment}"

  cors_config {
    access_control_allow_credentials = false

    access_control_allow_headers {
      items = ["*"]
    }

    access_control_allow_methods {
      items = ["ALL"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    origin_override = true
  }

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      override                   = true
    }

    content_type_options {
      override = true
    }

    frame_options {
      frame_option = "DENY"
      override     = true
    }

    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
  }
}

# S3 Bucket Policy for CloudFront OAC
resource "aws_s3_bucket_policy" "origin" {
  bucket = aws_s3_bucket.origin.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.origin.arn,
      "${aws_s3_bucket.origin.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}