terraform {
  backend "s3" {
    bucket         = "fbh-state-bucket"
    key            = "terraform.tfstate"       
    region         = "ap-south-1"               
    encrypt        = true                       
    dynamodb_table = "fbh-tfstate-lock"         
    acl            = "private"
  }
}
