locals {
  tags = {
    project     = var.project
  }
}




# --- ECR Repository ---
resource "aws_ecr_repository" "tomcat_repo" {
  name = var.ecr_tomcat_repo_name

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(
      local.tags,
      {
        Name = var.ecr_tomcat_repo_name
      }
  )
}

resource "aws_ecr_repository" "memcached_repo" {
  name = var.ecr_memcached_repo_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
      local.tags,
      {
        Name = var.ecr_memcached_repo_name
      }
  )
}

resource "aws_ecr_repository" "rabbitmq_repo" {
  name = var.ecr_rabbitmq_repo_name

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(
      local.tags,
      {
        Name = var.ecr_rabbitmq_repo_name
      }
  )
}

# --- IAM Role for ECS Task Execution ---
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# resource "aws_iam_role_policy" "rabbitmq_task_policy" {
#   name = "rabbitmq-efs-access"
#   role = aws_iam_role.ecs_task_execution_role.name

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = [
#           "elasticfilesystem:ClientMount",
#           "elasticfilesystem:ClientWrite",
#           "elasticfilesystem:ClientRootAccess"
#         ],
#         Effect   = "Allow",
#         Resource = aws_efs_access_point.rabbitmq_access_point.arn
#       }
#     ]
#   })
# }


# Custom inline policy to allow secrets access
# resource "aws_iam_role_policy" "ecs_secrets_access" {
#   name = "ecsSecretsAccessPolicy"
#   role = aws_iam_role.ecs_task_execution_role.id

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect   = "Allow",
#         Action   = [
#           "secretsmanager:GetSecretValue"
#         ],
#         Resource = [
#           aws_secretsmanager_secret.memcached_secret.arn,
#           aws_secretsmanager_secret.tomcat_secret.arn,
#           aws_secretsmanager_secret.rabbitmq_secret.arn
#         ]
#       }
#     ]
#   })
# }


# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group_tomcat" {
  name              = "/ecs/tomcat"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group_memcached" {
  name              = "/ecs/memcached"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group_rabbitmq" {
  name              = "/ecs/rabbitmq"
  retention_in_days = 7

  tags = local.tags
}



# --- ECS Cluster ---
resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.aws_ecs_cluster_name

  tags = merge(
      local.tags,
      {
        Name = var.aws_ecs_cluster_name
      }
  )
}


# --- Create a Cloud Map Namespace ---

resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "service.local"
  vpc         = var.vpc2_id
  description = "Service discovery for ECS services"
}


# --- Add Service Discovery to ECS Services ---

resource "aws_service_discovery_service" "tomcat" {
  name = "tomcat"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "memcached" {
  name = "memcached"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_service" "rabbitmq" {
  name = "rabbitmq"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}


# --- tomcat Service ---

locals {
  tomcat_secret_map = {
    JDBC_DRIVER                  = "com.mysql.jdbc.Driver"
    JDBC_URL                     = "jdbc:mysql://${var.rds_endpoint}:3306/accounts"
    JDBC_USERNAME                = "${var.db_username}"
    JDBC_PASSWORD                = "${var.db_password}"
    MEMCACHED_ACTIVE_HOST        = "memcached.service.local"
    MEMCACHED_ACTIVE_PORT        = "11211"
    MEMCACHED_STANDBY_HOST       = "memcached.service.local"
    MEMCACHED_STANDBY_PORT       = "11212"
    RABBITMQ_ADDRESS             = "rabbitmq.service.local"
    RABBITMQ_PORT                = "15672"
    RABBITMQ_USERNAME            = "guest"
    RABBITMQ_PASSWORD            = "rabbitmq-passw0rd"
  }

  tomcat_container_def = [
    {
      name  = "tomcat_auth_service"
      image = "${aws_ecr_repository.tomcat_repo.repository_url}:${var.tomcat_image_tag}"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]
      environment = [
        for key, value in local.tomcat_secret_map : {
          name  = key
          value = value
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/tomcat"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      # healthCheck = {
      #   command     = ["CMD-SHELL", "curl -f http://localhost:8081/health || exit 1"]
      #   interval    = 20
      #   timeout     = 3
      #   retries     = 3
      #   startPeriod = 30
      # }
    }
  ]
}



# --- ECS Task Definition - tomcat ---
resource "aws_ecs_task_definition" "tomcat_task" {
  family                   = "tomcat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode(local.tomcat_container_def)

  tags = merge(
    local.tags,
    {
      Name = "tomcat"
    }
  )
}


# --- ECS Service tomcat---
resource "aws_ecs_service" "tomcat_service" {
  name            = "tomcat_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.tomcat_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  tags = merge(
      local.tags,
      {
        Name = "tomcat_ecs_service"
      }
  )
}



# --- memcached Service ---

locals {
  memcached_env_map = {
    DB_NAME                        = "memcached"

  }

  memcached_container_def = [
    {
      name  = "memcached_service"
      image = "${aws_ecr_repository.memcached_repo.repository_url}:${var.memcached_image_tag}"
      portMappings = [
        {
          containerPort = 11211
          hostPort      = 11211
          protocol      = "tcp"
        }
      ]
      environment = [
        for key, value in local.memcached_env_map : {
          name  = key
          value = value
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/memcached"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      # healthCheck = {
      #   command     = ["CMD-SHELL", "curl -f http://localhost:3000/api/v1/health || exit 1"]
      #   interval    = 30
      #   timeout     = 5
      #   retries     = 3
      #   startPeriod = 10
      # }
    }
  ]
}




# --- ECS Task Definition - memcached ---
resource "aws_ecs_task_definition" "memcached_task" {
  family                   = "memcached"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode(local.memcached_container_def)

  tags = merge(
    local.tags,
    {
      Name = "memcached"
    }
  )
}



# --- ECS Service memcached---
resource "aws_ecs_service" "memcached_service" {
  name            = "memcached_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.memcached_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  tags = merge(
      local.tags,
      {
        Name = "memcached_ecs_service"
      }
  )
}

# --- EFS ---
# resource "aws_efs_file_system" "rabbitmq_efs" {
#   creation_token = "rabbitmq_efs"

#   tags = merge(
#       local.tags,
#       {
#         Name = "rabbitmq_efs"
#       }
#   )
# }


# resource "aws_efs_mount_target" "rabbitmq_mount_targets" {
#   for_each = toset(var.private_subnet_ids)

#   file_system_id  = aws_efs_file_system.rabbitmq_efs.id
#   subnet_id       = each.value
#   security_groups = [var.efs_sg_id]
# }



# --- EFS Access Point ---
# resource "aws_efs_access_point" "rabbitmq_access_point" {
#   file_system_id = aws_efs_file_system.rabbitmq_efs.id

#   # posix_user {
#   #   gid = 1000
#   #   uid = 1000
#   # }

#   root_directory {
#     path = "/rabbitmq-data"
#     creation_info {
#       owner_gid   = 0
#       owner_uid   = 0
#       permissions = "0777"
#     }
#   }

#   tags = {
#     Name = "rabbitmq_access_point"
#   }
# }



locals {
  rabbitmq_env_map = {
    RABBITMQ_DEFAULT_USER = "guest"
    RABBITMQ_DEFAULT_PASS = "rabbitmq-passw0rd"
  }

  rabbitmq_container_def = [
    {
      name  = "rabbitmq-service"
      image = "${aws_ecr_repository.rabbitmq_repo.repository_url}:${var.rabbitmq_image_tag}"
      portMappings = [
        {
          containerPort = 15672
          hostPort      = 15672
          protocol      = "tcp"
        }
      ]

      linuxParameters = {
        user = "0"
      }
      environment = [
        for key, value in local.rabbitmq_env_map : {
          name  = key
          value = value
        }
      ]
      # command = [
      #   "--requirepass", local.rabbitmq_env_map["rabbitmq_PASSWORD"],
      #   "--dir", "/data",
      #   "--dbfilename", "dump.rdb"
      # ]
      # mountPoints = [
      #   {
      #     containerPath = "/data"
      #     sourceVolume  = "rabbitmq-data"
      #     readOnly      = false
      #   }
      # ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/rabbitmq"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      # healthCheck = {
      #   command     = ["CMD-SHELL", "rabbitmq-cli -a $rabbitmq_PASSWORD PING"]
      #   interval    = 10
      #   timeout     = 5
      #   retries     = 6
      #   startPeriod = 15
      # }
    }
  ]
}




# --- ECS Task Definition for rabbitmq ---
resource "aws_ecs_task_definition" "rabbitmq_task" {
  family                   = "rabbitmq"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  # volume {
  #   name = "rabbitmq-data"
  #   efs_volume_configuration {
  #     file_system_id          = aws_efs_file_system.rabbitmq_efs.id
  #     transit_encryption      = "ENABLED"
  #     authorization_config {
  #       access_point_id = aws_efs_access_point.rabbitmq_access_point.id
  #       iam             = "ENABLED"
  #     }
  #   }
  # }

  container_definitions = jsonencode(local.rabbitmq_container_def)

  tags = {
    Name = "rabbitmq-task"
  }
}


# --- ECS Service for rabbitmq ---
resource "aws_ecs_service" "rabbitmq_service" {
  name            = "rabbitmq_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.rabbitmq_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  tags = {
    Name = "rabbitmq_ecs_service"
  }
}

