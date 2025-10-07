terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source for current AWS caller identity
data "aws_caller_identity" "current" {}

# Data source for VPC
data "aws_vpc" "main" {
  id = var.vpc_id
}

# Data source for private subnets with kubernetes tag
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  
  filter {
    name   = "tag:kubernetes.io/role/internal-elb"
    values = ["1"]
  }
}

# Fallback: Get ALL subnets if tagged subnets not found
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# Local variable to determine which subnets to use
locals {
  # Use private tagged subnets if available, otherwise fall back to all subnets
  # If neither works, use the variable-provided subnet_ids
  subnet_ids = length(data.aws_subnets.private.ids) > 0 ? data.aws_subnets.private.ids : (
    length(data.aws_subnets.all.ids) > 0 ? data.aws_subnets.all.ids : var.subnet_ids
  )
  
  # Validate that we have at least 2 subnets
  subnet_count = length(local.subnet_ids)
}

# Validation check
resource "null_resource" "validate_subnets" {
  count = local.subnet_count < 2 ? 1 : 0
  
  provisioner "local-exec" {
    command = "echo 'ERROR: EKS requires at least 2 subnets in different AZs. Found: ${local.subnet_count}' && exit 1"
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    }
  }
}

# EKS Module using terraform-aws-modules
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = local.subnet_ids  # ✅ FIXED: Use local variable with fallback logic

  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    main = {
      name = "main"

      iam_role_name            = "eks-ng-role-${var.cluster_name}"  # ✅ Make it unique per cluster
      iam_role_use_name_prefix = false

      instance_types = var.node_group_instance_types
      capacity_type  = var.node_group_capacity_type

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      subnet_ids = local.subnet_ids  # ✅ Use same subnet logic

      ami_type  = var.node_group_ami_type
      disk_size = var.node_group_disk_size

      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      taints = var.node_group_taints

      tags = merge(
        var.common_tags,
        {
          "NodeGroup" = "main"
        }
      )
    }
  }

  # aws-auth configmap
  manage_aws_auth_configmap = var.manage_aws_auth_configmap

  aws_auth_roles = var.aws_auth_roles
  aws_auth_users = var.aws_auth_users

  tags = var.common_tags

  depends_on = [null_resource.validate_subnets]
}