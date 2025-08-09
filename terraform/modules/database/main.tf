locals {
  tags = {
    project = var.project
  }
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = merge(
      local.tags,
      {
        Name = var.db_subnet_group_name
      }
  )
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = var.db_parameter_group_name
  family      = "mysql8.0"
  description = "Custom parameter group for MySQL 8.0"

  parameter {
    name  = "general_log"
    value = "1"
  }
}

resource "aws_db_instance" "rds" {
  identifier              = var.db_identifier
  engine                  = "mysql"
  engine_version          = "8.0.41"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [var.security_group_id]
  parameter_group_name    = aws_db_parameter_group.rds_parameter_group.name
  availability_zone       = var.availability_zones[0]
  multi_az                = false
  skip_final_snapshot     = true
  publicly_accessible     = false 
  port                    = 3306
  apply_immediately       = true

  tags = merge(
      local.tags,
      {
        Name = var.db_identifier
      }
  )
  
}


