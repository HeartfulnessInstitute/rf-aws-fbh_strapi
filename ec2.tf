# ec2.tf

# Normalize private subnet ids (works if module.vpc returns list or map)
locals {
  ec2_private_subnet_ids = try(values(module.vpc.private_subnet_ids), module.vpc.private_subnet_ids)

  # Try several common module output names for the ALB SG, then fall back to a variable,
  # otherwise empty string. Terraform's try() will return the first expression that succeeds.
  alb_sg_id = try(
    module.alb.security_group_id,        # common output name
    module.alb.alb_sg_id,                # alternate
    module.alb.alb_security_group_id,    # alternate
    var.alb_security_group_id,           # explicit variable (if provided)
    ""                                   # fallback empty
  )
}

# -------------------------
# EC2 security group (no SSH, no public ingress)
# -------------------------
resource "aws_security_group" "ec2_sg" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Security group for EC2 app server - allow traffic only from ALB"
  vpc_id      = module.vpc.vpc_id

  # No SSH ingress and no 0.0.0.0/0 HTTP; explicit rules below

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-ec2-sg"
    }
  )
}


# -------------------------
# ALB -> EC2 ingress 
# -------------------------

resource "aws_security_group_rule" "allow_alb_to_ec2" {
  type                     = "ingress"
  from_port                = var.target_port      
  to_port                  = var.target_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_sg.id
  source_security_group_id = module.alb.alb_security_group_id
  description              = "Allow ALB to reach EC2 on app port"
}


# -------------------------
# Allow EC2 SG -> DB SG (security-group based ingress)
# -------------------------
resource "aws_security_group_rule" "allow_ec2_to_db" {
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_sg.id
  source_security_group_id = aws_security_group.ec2_sg.id
  description              = "Allow EC2 app servers to reach the DB"
}

# -------------------------
# EC2 instance (placed in private subnet, no public IP)
# -------------------------
resource "aws_instance" "app_server" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  subnet_id              = local.ec2_private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  # We intentionally don't expose a public IP for instances behind the ALB.
  associate_public_ip_address = false


  tags = merge(var.tags, {
    Name = "${var.name_prefix}-ec2"
  })
}
