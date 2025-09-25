resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-${var.environment}-db"
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class

  # Only pass db_name when non-empty. Passing null omits the parameter.
  db_name                = var.db_name != "" ? var.db_name : null

  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
  }
}
