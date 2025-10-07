# Development Environment Configuration
aws_region = "ap-south-1"

# VPC Configuration (from VPC module output or existing VPC)
vpc_id = "vpc-0fe2100814b6bf8dc" # Replace with actual VPC ID from VPC module
  subnet_ids = [
    "subnet-01182cde8537543ea",  # Replace with your actual subnet IDs
    "subnet-08dbade0d7e59c1b8",
    "subnet-090a6dac9c3da25ec" ,
    "subnet-01cd7c12d51c6820c",
  ]

# EKS Configuration
cluster_name    = "fbh-dev-cluster"
cluster_version = "1.28"
environment     = "dev"

# Cluster Endpoint Configuration
cluster_endpoint_public_access  = true
cluster_endpoint_private_access = true

# Node Group Configuration
node_group_instance_types = ["t3.medium"]
node_group_capacity_type  = "ON_DEMAND"
node_group_desired_size   = 2
node_group_max_size       = 3
node_group_min_size       = 1
node_group_ami_type       = "AL2_x86_64"
node_group_disk_size      = 20


# AWS Auth Configuration
manage_aws_auth_configmap = true

aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/AdminRole"  # Replace ACCOUNT_ID
    username = "admin"
    groups   = ["system:masters"]
  }
]

aws_auth_users = [
  {
    userarn  = "arn:aws:iam::ACCOUNT_ID:user/admin"  # Replace ACCOUNT_ID
    username = "admin"
    groups   = ["system:masters"]
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
}

# Common Tags
common_tags = {
  Environment = "dev"
  Project     = "eks-fbh"
  ManagedBy   = "terraform"
  Owner       = "DevOps-Team"
  CostCenter  = "development"
}
letsencrypt_email = "admin@heartfulness.org"