# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro" # change if needed
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_pair_name

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-${var.app_name}"
      Environment = var.environment
      Project     = var.project_name
      Application = var.app_name
    }
  )

  user_data = <<-EOF
              #!/bin/bash
              echo "DB_HOST=${var.rds_endpoint}" >> /etc/environment
              echo "DB_NAME=${var.db_name}" >> /etc/environment
              echo "DB_USER=${var.db_username}" >> /etc/environment
              echo "DB_PASS=${var.db_password}" >> /etc/environment
              echo "S3_BUCKET=${var.s3_bucket_name}" >> /etc/environment

              # Install updates and docker (example)
              yum update -y
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              EOF
}
