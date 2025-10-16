terraform {
  backend "s3" {
   bucket = "fbh-state-bucket"
key = "envs/dev/terraform.tfstate"
region = "ap-south-1"
encrypt = true
dynamodb_table = "fbh-tfstate-lock-dev"
acl = "private"
  }
}
