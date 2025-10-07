# Production Environment Configuration
aws_region = "ap-south-1"

# VPC Configuration (from VPC module output or existing VPC)
vpc_id = "vpc-zzzzzzzzzz"  # Replace with actual VPC ID from VPC module

# EKS Configuration
cluster_name    = "eks-prod-cluster"
cluster_version = "1.28"
environment     = "prod"

# Cluster Endpoint Configuration - Production security settings
cluster_endpoint_public_access  = false   # Private access only for production
cluster_endpoint_private_access = true

# Node Group Configuration - Production-grade instances
node_group_instance_types = ["m5.xlarge", "m5.2xlarge"]  # Mixed instance types
node_group_capacity_type  = "ON_DEMAND"                  # Reliability over cost for prod
node_group_desired_size   = 6                            # Higher capacity for production
node_group_max_size       = 12                           
node_group_min_size       = 3                            # Minimum for HA
node_group_ami_type       = "AL2_x86_64"
node_group_disk_size      = 100                          



# AWS Auth Configuration
manage_aws_auth_configmap = true

aws_auth_roles = [
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/AdminRole"  # Replace ACCOUNT_ID
    username = "admin"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/DevOpsRole"  # Replace ACCOUNT_ID
    username = "devops"
    groups   = ["system:masters"]
  },
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/DeveloperRole"  # Replace ACCOUNT_ID
    username = "developer"
    groups   = ["system:authenticated"]
  },
  {
    rolearn  = "arn:aws:iam::ACCOUNT_ID:role/ReadOnlyRole"  # Replace ACCOUNT_ID
    username = "readonly"
    groups   = ["system:authenticated"]
  }
]

aws_auth_users = [
  {
    userarn  = "arn:aws:iam::ACCOUNT_ID:user/prod-admin"  # Replace ACCOUNT_ID
    username = "prod-admin"
    groups   = ["system:masters"]
  },
  {
    userarn  = "arn:aws:iam::ACCOUNT_ID:user/prod-operator"  # Replace ACCOUNT_ID
    username = "prod-operator"
    groups   = ["system:authenticated"]
  }
]

# EKS Add-ons - Production with additional monitoring and security
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
  # Additional addons for production
  adot = {
    version                  = "v0.88.0-eksbuild.1"
    service_account_role_arn = null
  }
}

# Node Group Taints for production workloads
node_group_taints = {
  production = {
    key    = "production"
    value  = "true"
    effect = "NO_SCHEDULE"
  }
}

# Common Tags - Production specific
common_tags = {
  Environment = "prod"
  Project     = "eks-demo"
  ManagedBy   = "terraform"
  Owner       = "DevOps-Team"
  CostCenter  = "production"
  Backup      = "required"
  Monitoring  = "enabled"
  Compliance  = "required"
  DataClassification = "confidential"
  MaintenanceWindow = "sunday-2am-4am"
}