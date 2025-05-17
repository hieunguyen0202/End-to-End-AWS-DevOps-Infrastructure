resource "random_password" "secret_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "mongodb_password_secret" {
  name = "aws-infra-01-mongodb-password-secret"
}

resource "aws_secretsmanager_secret_version" "mongodb_password_secret_version" {
  secret_id     = aws_secretsmanager_secret.mongodb_password_secret.id
  secret_string = random_password.secret_password.result
}


resource "aws_docdb_cluster_parameter_group" "parameter_group" {
  name        = var.parameter_group_name
  family      = var.parameter_group_family
  description = "Custom parameter group for DocumentDB"

  parameter {
    name  = "tls"
    value = "disabled"
  }

  tags = {
    Name = var.parameter_group_name
  }
}

resource "aws_docdb_subnet_group" "subnet_group" {
  name       = var.subnet_group_name
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = var.subnet_group_name
  }
}

resource "aws_docdb_cluster" "cluster" {
  cluster_identifier              = var.cluster_identifier
  engine                          = "docdb"
  engine_version                  = var.engine_version
  master_username                 = var.master_username
  master_password                 = aws_secretsmanager_secret_version.mongodb_password_secret_version.secret_string
  vpc_security_group_ids          = [var.security_group_id]
  db_subnet_group_name            = aws_docdb_subnet_group.subnet_group.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.parameter_group.name
  storage_encrypted               = true
  skip_final_snapshot             = true
  deletion_protection             = false

  tags = {
    Name = var.cluster_identifier
  }
}

resource "aws_docdb_cluster_instance" "cluster_instance" {
  count              = var.instance_count
  identifier         = "${var.cluster_identifier}-instance-${count.index + 1}"
  cluster_identifier = aws_docdb_cluster.cluster.id
  instance_class     = var.instance_class

  tags = {
    Name = "${var.cluster_identifier}-instance-${count.index + 1}"
  }
}

#TODO: Create a secret for the connection string
resource "aws_secretsmanager_secret" "mongodb_connection_string" {
  name = "aws-infra-01-mongodb-connection-string"
}


resource "aws_secretsmanager_secret_version" "mongodb_connection_string_version" {
  secret_id     = aws_secretsmanager_secret.mongodb_connection_string.id
  secret_string =  "mongodb://${var.master_username}:${aws_secretsmanager_secret_version.mongodb_password_secret_version.secret_string}@${aws_docdb_cluster.cluster.endpoint}:27017/dev"
}