locals {
  tags = {
    project     = var.project
  }
}


# Terraform – Create NLB + Target Group + Listener
# Network Load Balancer
resource "aws_lb" "app_nlb" {
  name               = "ecs-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = var.private_subnet_ids
  
  tags = local.tags
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name        = "ecs-tg"
  port        = var.container_port
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = var.vpc2_id

  health_check {
    protocol            = "TCP"
    port                = var.container_port
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = local.tags
}

# Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}





# --- ECR Repository ---
resource "aws_ecr_repository" "app_repo" {
  name = var.ecr_repo_name

  tags = merge(
      local.tags,
      {
        Name = var.ecr_repo_name
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

# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name              = "/ecs/${var.backend_service_name}"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group_rabbitmq" {
  name              = "/ecs/rabbitmq"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group_memcached" {
  name              = "/ecs/memcached"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group_mysql" {
  name              = "/ecs/mysql"
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

resource "aws_service_discovery_service" "mysql" {
  name = "mysql"
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







# --- Define ECS Task Definitions (RabbitMQ, Memcached, MySQL) ---
resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "rabbitmq"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "rabbitmq"
      image = "rabbitmq:3-management"
      portMappings = [
        { containerPort = 5672, hostPort = 5672, protocol = "tcp" },
        { containerPort = 15672, hostPort = 15672, protocol = "tcp" }
      ]

      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "/ecs/rabbitmq"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }
    }
  ])
}


resource "aws_ecs_service" "rabbitmq_service" {
  name            = "rabbitmq"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.rabbitmq.arn
  }

  tags = merge(
      local.tags,
      {
        Name = "rabbitmq"
      }
  )
}



resource "aws_ecs_task_definition" "memcached" {
  family                   = "memcached"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "memcached"
      image = "memcached:latest"
      portMappings = [
        { containerPort = 11211, hostPort = 11211, protocol = "tcp" }
      ]

      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "/ecs/memcached"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }
    }
  ])
}


resource "aws_ecs_service" "memcached_service" {
  name            = "memcached"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.memcached.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.memcached.arn
  }

  tags = merge(
      local.tags,
      {
        Name = "memcached"
      }
  )
}


resource "aws_efs_file_system" "mysql_efs" {
  creation_token = "mysql-efs"

  tags = merge(
      local.tags,
      {
        Name = "mysql-efs"
      }
  )
}

resource "aws_efs_mount_target" "mysql_efs_mt" {
  file_system_id  = aws_efs_file_system.mysql_efs.id
  subnet_id       = var.private_subnet_ids[0]   
  security_groups = [var.efs_sg_id]
}


resource "aws_efs_access_point" "mysql_ap" {
  file_system_id = aws_efs_file_system.mysql_efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/mysql"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }

  tags = merge(
      local.tags,
      {
        Name = "mysql-access-point"
      }
  )

}



resource "aws_ecs_task_definition" "mysql" {
  family                   = "mysql"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  volume {
    name = "mysql-data"

    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.mysql_efs.id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.mysql_ap.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name  = "mysql"
      image = "mysql:5.7"
      portMappings = [
        { containerPort = 3306, hostPort = 3306, protocol = "tcp" }
      ]
      environment = [
        { name = "MYSQL_ROOT_PASSWORD", value = "vprodbpass" },
        { name = "MYSQL_DATABASE", value = "accounts" }
      ]

      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "/ecs/mysql"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
      }

      mountPoints = [
        {
          sourceVolume  = "mysql-data"
          containerPath = "/var/lib/mysql"
          readOnly      = false
        }
      ]
    }
  ])
}


resource "aws_ecs_service" "mysql_service" {
  name            = "mysql"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.mysql.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.mysql.arn
  }

  tags = merge(
      local.tags,
      {
        Name = "mysql"
      }
  )
}




# --- ECS Task Definition ---
resource "aws_ecs_task_definition" "app_task" {
  family                   = var.backend_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.backend_service_name
      image     = "${aws_ecr_repository.app_repo.repository_url}:${var.backend_image_tag}"
      portMappings = [{
        containerPort = var.container_port,
        hostPort      = var.host_port,
        protocol      = "tcp"
      }],

      environment = [
        { name = "JDBC_URL", value = "jdbc:mysql://mysql.service.local:3306/accounts" },
        { name = "JDBC_USERNAME", value = "root" },
        { name = "JDBC_PASSWORD", value = "vprodbpass" },

        { name = "MEMCACHED_ACTIVE_HOST", value = "memcached.service.local" },
        { name = "MEMCACHED_ACTIVE_PORT", value = "11211" },
        { name = "MEMCACHED_STANDBY_HOST", value = "rabbitmq.service.local" },
        { name = "MEMCACHED_STANDBY_PORT", value = "11211" },

        { name = "RABBITMQ_ADDRESS", value = "rabbitmq.service.local" },
        { name = "RABBITMQ_PORT", value = "15672" },
        { name = "RABBITMQ_USERNAME", value = "guest" },
        { name = "RABBITMQ_PASSWORD", value = "guest" }
      ],
      
      logConfiguration = {
          logDriver = "awslogs",
          options = {
            awslogs-group         = "/ecs/${var.backend_service_name}"
            awslogs-region        = var.aws_region
            awslogs-stream-prefix = "ecs"
          }
        }
    }
  ])

  tags = merge(
      local.tags,
      {
        Name = var.aws_ecs_task_definition_name
      }
  )
}

# --- ECS Service ---
resource "aws_ecs_service" "app_service" {
  name            = var.aws_ecs_service
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = var.backend_service_name
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.app_listener]


  tags = merge(
      local.tags,
      {
        Name = var.aws_ecs_service
      }
  )
}

