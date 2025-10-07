# Staging Environment Configuration
aws_region = "ap-south-1"

# VPC Configuration (from VPC module output or existing VPC)
vpc_id = "vpc-0cebb82add4d1cc1b"  # Replace with actual VPC ID from VPC module

# EKS Configuration
cluster_name    = "eks-staging-cluster"
cluster_version = "1.28"
environment     = "staging"

# Cluster Endpoint Configuration
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true

# Node Group Configuration
node_group_instance_types = ["t3.large"]  # Larger instance for staging
node_group_capacity_type  = "ON_DEMAND"
node_group_desired_size   = 3             # More nodes for staging
node_group_max_size       = 6
node_group_min_size       = 2
node_group_ami_type       = "AL2_x86_64"
node_group_disk_size      = 50            # Larger disk for staging


# AWS Auth Configuration
manage_aws_auth_configmap = true

aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/AdminRole"  # Replace ACCOUNT_ID
    username = "admin"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/DeveloperRole"  # Replace ACCOUNT_ID
    username = "developer"
    groups   = ["system:authenticated"]
  }
]

aws_auth_users = [
  {
    userarn  = "arn:aws:iam::ACCOUNT_ID:user/admin"  # Replace ACCOUNT_ID
    username = "admin"
    groups   = ["system:masters"]
  },
  {
    userarn  = "arn:aws:iam::ACCOUNT_ID:user/staging-user"  # Replace ACCOUNT_ID
    username = "staging-user"
    groups   = ["system:authenticated"]
  }
]

# EKS Add-ons
eks_addons = {
  coredns = {
    version                  = "v1.10.1-eksbuild.5"
    service_account_role_arn = null
  }
  kube-proxy = {
    version                  = "v1.28.2-eksbuild.2"
    service_account_role_arn = null
  }
  vpc-cni = {
    version                  = "v1.15.1-eksbuild.1"
    service_account_role_arn = null
  }
  aws-ebs-csi-driver = {
    version                  = "v1.24.0-eksbuild.1"
    service_account_role_arn = null
  }
  aws-efs-csi-driver = {
    version                  = "v1.7.0-eksbuild.1"
    service_account_role_arn = null
  }
}

# Common Tags
common_tags = {
  Environment = "staging"
  Project     = "eks-demo"
  ManagedBy   = "terraform"
  Owner       = "DevOps-Team"
  CostCenter  = "staging"
}