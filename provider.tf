terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider (used by resources that reference `aws`)
provider "aws" {
  region = "ap-south-1"
  # optionally use profile or env creds
  # profile = "fbh"
}

