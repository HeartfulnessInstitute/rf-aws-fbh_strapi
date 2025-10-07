# EKS Addons (including Pod Identity Agent)
resource "aws_eks_addon" "addons" {
  for_each = var.eks_addons

  cluster_name             = module.eks.cluster_name
  addon_name               = each.key
  addon_version            = each.value.version
  service_account_role_arn = each.value.service_account_role_arn

  depends_on = [module.eks]
}

# IAM Role for Cert Manager
resource "aws_iam_role" "cert_manager" {
  count = var.enable_cert_manager ? 1 : 0
  name  = "${var.cluster_name}-cert-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:cert-manager:cert-manager"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for Cert Manager (Route53 access)
resource "aws_iam_policy" "cert_manager_route53" {
  count = var.enable_cert_manager ? 1 : 0
  name  = "${var.cluster_name}-cert-manager-route53-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "route53:GetChange"
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect = "Allow"
        Action = "route53:ListHostedZonesByName"
        Resource = "*"
      }
    ]
  })

  tags = var.common_tags
}

# Attach policy to Cert Manager role
resource "aws_iam_role_policy_attachment" "cert_manager_route53" {
  count      = var.enable_cert_manager ? 1 : 0
  role       = aws_iam_role.cert_manager[0].name
  policy_arn = aws_iam_policy.cert_manager_route53[0].arn
}

# IAM Role for External DNS
resource "aws_iam_role" "external_dns" {
  count = var.enable_external_dns ? 1 : 0
  name  = "${var.cluster_name}-external-dns-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:external-dns:external-dns"
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = var.common_tags
}

# IAM Policy for External DNS (Route53 access)
resource "aws_iam_policy" "external_dns_route53" {
  count = var.enable_external_dns ? 1 : 0
  name  = "${var.cluster_name}-external-dns-route53-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "route53:ChangeResourceRecordSets"
        ]
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect = "Allow"
        Action = [
          "route53:ListHostedZones",
          "route53:ListResourceRecordSets"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.common_tags
}

# Attach policy to External DNS role
resource "aws_iam_role_policy_attachment" "external_dns_route53" {
  count      = var.enable_external_dns ? 1 : 0
  role       = aws_iam_role.external_dns[0].name
  policy_arn = aws_iam_policy.external_dns_route53[0].arn
}

# Cert Manager Helm Release
resource "helm_release" "cert_manager" {
  count      = var.enable_cert_manager ? 1 : 0
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = var.cert_manager_version

  create_namespace = true

  set {
    name  = "crds.enabled"
    value = "true"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.cert_manager[0].arn
  }

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.cert_manager_route53
  ]
}

# External DNS Helm Release
resource "helm_release" "external_dns" {
  count      = var.enable_external_dns ? 1 : 0
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "external-dns"
  version    = var.external_dns_version

  create_namespace = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.external_dns[0].arn
  }

  set {
    name  = "provider"
    value = "aws"
  }

  set {
    name  = "aws.region"
    value = var.aws_region
  }

  set {
    name  = "txtOwnerId"
    value = var.cluster_name
  }

  set {
    name  = "domainFilters[0]"
    value = var.domain_name
  }

  depends_on = [
    module.eks,
    aws_iam_role_policy_attachment.external_dns_route53
  ]
}

# ClusterIssuer for Let's Encrypt (optional)
resource "kubernetes_manifest" "letsencrypt_issuer" {
  count = var.enable_cert_manager && var.enable_letsencrypt_issuer ? 1 : 0

  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-production"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-production"
        }
        solvers = [
          {
            dns01 = {
              route53 = {
                region = var.aws_region
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]

  
}