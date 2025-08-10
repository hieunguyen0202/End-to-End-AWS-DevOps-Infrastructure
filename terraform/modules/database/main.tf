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

######################
# Aurora MySQL Mode
######################
resource "aws_rds_cluster" "aurora" {
  count                   = var.db_mode == "aurora" ? 1 : 0
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.05.2"
  master_username         = var.db_username
  master_password         = var.db_password
  database_name           = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [var.security_group_id]
  storage_encrypted       = true
  backup_retention_period = 7
  preferred_backup_window = "02:00-03:00"
  skip_final_snapshot       = true
  # final_snapshot_identifier = "aurora-final-snapshot-${formatdate("YYYYMMDDHHmmss", timestamp())}"

  tags = merge(
      local.tags,
      {
        Name = "aurora-cluster"
      }
  )
}

resource "aws_rds_cluster_instance" "aurora_writer" {
  count              = var.db_mode == "aurora" ? 1 : 0
  identifier         = "aurora-writer"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora[0].engine
  engine_version     = aws_rds_cluster.aurora[0].engine_version

  tags = merge(
      local.tags,
      {
        Name = "aurora-writer"
      }
  )
}

resource "aws_rds_cluster_instance" "aurora_reader" {
  count              = var.db_mode == "aurora" ? 1 : 0
  identifier         = "aurora-reader"
  cluster_identifier = aws_rds_cluster.aurora[0].id
  instance_class     = "db.t3.medium"
  engine             = aws_rds_cluster.aurora[0].engine
  engine_version     = aws_rds_cluster.aurora[0].engine_version

  tags = merge(
      local.tags,
      {
        Name = "aurora-reader"
      }
  )
}


######################
# MySQL Multi-AZ Mode
######################

resource "aws_db_instance" "mysql_primary" {
  count                   = var.db_mode == "mysql" ? 1 : 0
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
  multi_az                = true
  skip_final_snapshot     = true
  publicly_accessible     = false 
  port                    = 3306
  # apply_immediately       = true

  tags = merge(
      local.tags,
      {
        Name = var.db_identifier
      }
  )
  
}


# Read Replica
resource "aws_db_instance" "mysql_replica" {
  count                  = var.db_mode == "mysql" ? 1 : 0
  identifier             = "mysql-replica"
  replicate_source_db    = aws_db_instance.mysql_primary[0].identifier
  instance_class         = "db.t3.micro"
  publicly_accessible    = false

  tags = merge(
      local.tags,
      {
        Name = "mysql-replica"
      }
  )
}


######################
# Snapshot & Cross-region Copy
######################

# KMS key for the primary region
resource "aws_kms_key" "rds_snapshot_key_primary" {
  description             = "KMS key for cross-region RDS snapshot copy in primary region"
  deletion_window_in_days = 10

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
      {
        "Sid": "Allow administration of the key",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key for RDS snapshot copy",
        "Effect": "Allow",
        "Principal": {
          "Service": "rds.amazonaws.com"
        },
        "Action": [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}


# KMS key for the DR region - This is the crucial fix
resource "aws_kms_key" "rds_snapshot_key_dr" {
  provider = aws.dr # This tells Terraform to create this key in the 'dr' region.

  description             = "KMS key for cross-region RDS snapshot copy in DR region"
  deletion_window_in_days = 10

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
      {
        "Sid": "Allow administration of the key",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key for RDS snapshot copy",
        "Effect": "Allow",
        "Principal": {
          "Service": "rds.amazonaws.com"
        },
        "Action": [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}


resource "aws_db_snapshot" "manual_snapshot" {
  count                   = var.enable_snapshot && var.db_mode == "mysql" ? 1 : 0
  db_instance_identifier  = aws_db_instance.mysql_primary[0].identifier
  db_snapshot_identifier  = "mysql-snapshot"
}

resource "aws_db_cluster_snapshot" "aurora_snapshot" {
  count                  = var.enable_snapshot && var.db_mode == "aurora" ? 1 : 0
  db_cluster_identifier  = aws_rds_cluster.aurora[0].id
  db_cluster_snapshot_identifier = "aurora-snapshot"
}

provider "aws" {
  alias  = "dr"
  region = var.dr_region
}

data "aws_caller_identity" "current" {}

# Create KMS key
resource "aws_kms_key" "rds_snapshot_key" {
  description             = "KMS key for cross-region RDS snapshot copy"
  deletion_window_in_days = 10

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "key-default-1",
    "Statement": [
      {
        "Sid": "Allow administration of the key",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key for RDS snapshot copy",
        "Effect": "Allow",
        "Principal": {
          "Service": "rds.amazonaws.com"
        },
        "Action": [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}



resource "aws_db_snapshot_copy" "mysql_snapshot_copy" {
  count                         = var.enable_snapshot && var.db_mode == "mysql" ? 1 : 0
  provider                      = aws.dr
  source_db_snapshot_identifier = aws_db_snapshot.manual_snapshot[0].db_snapshot_arn
  target_db_snapshot_identifier = "mysql-snapshot-copy"
  kms_key_id                    = aws_kms_key.rds_snapshot_key_dr.arn
}

resource "aws_rds_cluster_snapshot_copy" "aurora_snapshot_copy" {
  count  = var.enable_snapshot && var.db_mode == "aurora" ? 1 : 0
  provider = aws.dr

  source_db_cluster_snapshot_identifier = aws_db_cluster_snapshot.aurora_snapshot[0].db_cluster_snapshot_arn
  target_db_cluster_snapshot_identifier = "aurora-snapshot-copy"
  kms_key_id = aws_kms_key.rds_snapshot_key_dr.arn
}


############################
# SNS Topic for Alerts
############################
resource "aws_sns_topic" "db_alerts" {
  name = "db-alerts-topic"
}

resource "aws_sns_topic_subscription" "db_alerts_email" {
  topic_arn = aws_sns_topic.db_alerts.arn
  protocol  = "email"
  endpoint  = "samelnguyen08@gmail.com"  # Nhập email nhận cảnh báo
}

############################
# CPU Utilization Alarm
############################
resource "aws_cloudwatch_metric_alarm" "db_cpu_alarm" {
  count               = var.db_mode == "aurora" ? 1 : var.db_mode == "mysql" ? 1 : 0
  alarm_name          = "${var.db_mode}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "CPU utilization > 80% for ${var.db_mode} DB"
  alarm_actions       = [aws_sns_topic.db_alerts.arn]

  dimensions = var.db_mode == "aurora" ? {
    DBClusterIdentifier = aws_rds_cluster.aurora[0].id
  } : {
    DBInstanceIdentifier = aws_db_instance.mysql_primary[0].id
  }
}

############################
# Read IOPS Alarm
############################
resource "aws_cloudwatch_metric_alarm" "db_read_iops_alarm" {
  count               = var.db_mode == "aurora" ? 1 : var.db_mode == "mysql" ? 1 : 0
  alarm_name          = "${var.db_mode}-read-iops"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "ReadIOPS"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 5000
  alarm_description   = "Read IOPS > 5000 for ${var.db_mode} DB"
  alarm_actions       = [aws_sns_topic.db_alerts.arn]

  dimensions = var.db_mode == "aurora" ? {
    DBClusterIdentifier = aws_rds_cluster.aurora[0].id
  } : {
    DBInstanceIdentifier = aws_db_instance.mysql_primary[0].id
  }
}

############################
# Write IOPS Alarm
############################
resource "aws_cloudwatch_metric_alarm" "db_write_iops_alarm" {
  count               = var.db_mode == "aurora" ? 1 : var.db_mode == "mysql" ? 1 : 0
  alarm_name          = "${var.db_mode}-write-iops"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 5
  metric_name         = "WriteIOPS"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 5000
  alarm_description   = "Write IOPS > 5000 for ${var.db_mode} DB"
  alarm_actions       = [aws_sns_topic.db_alerts.arn]

  dimensions = var.db_mode == "aurora" ? {
    DBClusterIdentifier = aws_rds_cluster.aurora[0].id
  } : {
    DBInstanceIdentifier = aws_db_instance.mysql_primary[0].id
  }
}