# Subnet group for RDS (must be in private subnets)
resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-${var.environment}-${var.app_name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-${var.app_name}-rds-subnet-group"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# RDS instance
resource "aws_db_instance" "this" {
  identifier             = "${var.project_name}-${var.environment}-${var.app_name}-rds"
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.db_password
  port                   = var.port
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection

  vpc_security_group_ids = [var.security_group_id]
  db_subnet_group_name   = aws_db_subnet_group.this.name

  storage_encrypted      = true
  backup_retention_period = var.backup_retention_period
  multi_az               = var.multi_az

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-${var.app_name}-rds"
      Environment = var.environment
      Project     = var.project_name
    }
  )
}
