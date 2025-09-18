resource "aws_amplify_app" "main" {
  name       = var.app_name
  repository = var.repository_url

  build_spec = var.build_spec
  environment_variables = var.environment_variables

  dynamic "custom_rule" {
    for_each = var.custom_rules
    content {
      source = custom_rule.value.source
      status = custom_rule.value.status
      target = custom_rule.value.target
    }
  }

  enable_auto_branch_creation = var.enable_auto_branch_creation

  auto_branch_creation_config {
    enable_auto_build           = var.auto_branch_enable_auto_build
    environment_variables       = var.auto_branch_environment_variables
    framework                   = var.framework
    enable_pull_request_preview = var.enable_pull_request_preview
  }

  platform = var.platform
  access_token = var.access_token != "" ? var.access_token : null

  tags = var.tags
}

resource "aws_amplify_branch" "branches" {
  for_each = var.branches

  app_id      = aws_amplify_app.main.id
  branch_name = each.key

  environment_variables       = each.value.environment_variables
  framework                  = each.value.framework
  enable_auto_build          = each.value.enable_auto_build
  enable_pull_request_preview = each.value.enable_pull_request_preview

  tags = var.tags
}

resource "aws_amplify_domain_association" "main" {
  count = var.domain_name != "" ? 1 : 0

  app_id      = aws_amplify_app.main.id
  domain_name = var.domain_name

  dynamic "sub_domain" {
    for_each = var.sub_domains
    content {
      branch_name = sub_domain.value.branch_name
      prefix      = sub_domain.value.prefix
    }
  }

  wait_for_verification = true
}

resource "aws_amplify_webhook" "main" {
  count = var.create_webhook ? 1 : 0

  app_id      = aws_amplify_app.main.id
  branch_name = var.webhook_branch_name
  description = "Webhook for ${var.app_name}"
}