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
  port              = "80"
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
      }],
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

