locals {
  tags = {
    project     = var.project
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
      }]
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

  tags = merge(
      local.tags,
      {
        Name = var.aws_ecs_service
      }
  )
}

