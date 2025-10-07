variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be created"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "node_group_instance_types" {
  description = "EC2 instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_capacity_type" {
  description = "Capacity type for the node group (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_group_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "node_group_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_group_ami_type" {
  description = "AMI type for the node group"
  type        = string
  default     = "AL2_x86_64"
}

variable "node_group_disk_size" {
  description = "Disk size for node group instances"
  type        = number
  default     = 20
}

variable "node_group_taints" {
  description = "Taints to apply to the node group"
  type        = map(any)
  default     = {}
}

variable "key_pair_name" {
  description = "EC2 Key Pair name for SSH access to nodes (optional)"
  type        = string
  default     = null
}

variable "manage_aws_auth_configmap" {
  description = "Whether to manage the aws-auth configmap"
  type        = bool
  default     = true
}

variable "aws_auth_roles" {
  description = "List of role maps to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_users" {
  description = "List of user maps to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "eks_addons" {
  description = "Map of EKS add-ons to install"
  type = map(object({
    version                  = string
    service_account_role_arn = string
  }))
  default = {}
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default     = {}
}

# New variables for add-ons
variable "enable_cert_manager" {
  description = "Enable cert-manager installation"
  type        = bool
  default     = true
}

variable "cert_manager_version" {
  description = "Version of cert-manager to install"
  type        = string
  default     = "v1.13.0"
}

variable "enable_external_dns" {
  description = "Enable external-dns installation"
  type        = bool
  default     = true
}

variable "external_dns_version" {
  description = "Version of external-dns to install"
  type        = string
  default     = "1.13.0"
}

variable "domain_name" {
  description = "Domain name for external-dns to manage"
  type        = string
  default     = ""
}

variable "enable_letsencrypt_issuer" {
  description = "Enable Let's Encrypt ClusterIssuer creation"
  type        = bool
  default     = false
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt certificate notifications"
  type        = string
  default     = ""
}
variable "iam_role_name" {
  type        = string
  description = "Custom IAM role name"
  default     = "eks-ng-role"
}

variable "iam_role_use_name_prefix" {
  type        = bool
  description = "Whether to use name_prefix for IAM roles"
  default     = false
}
variable "control_plane_subnet_ids" {
  description = "Subnet IDs for control plane (optional)"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "Worker subnet IDs (optional)"
  type        = list(string)
  default     = []
}
