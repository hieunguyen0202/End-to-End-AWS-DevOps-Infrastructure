resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name

  tags = {
    Name = var.ecs_cluster_name
  }
}

resource "aws_iam_role" "task_execution_role" {
  name = var.task_exec_role_name

  assume_role_policy = data.aws_iam_policy_document.task_exec_assume.json
}

data "aws_iam_policy_document" "task_exec_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_policy" "task_execution_policy" {
  name        = "final-assignment-task-execution-policy"
  description = "Policy for ECS task execution role"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}


resource "aws_iam_role_policy_attachment" "task_execution_policy_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}


resource "aws_iam_role" "ecs_task_role" {
  name = "aws-infra-01-ecs-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_assume.json
}

data "aws_iam_policy_document" "ecs_task_exec_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_policy" "ecs_task_role_policy" {
  name        = "final-assignment-task-role-policy"
  description = "Policy for ECS task role"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_role_policy.arn
}



resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/aws-infra-01-project"
  retention_in_days = 7

  tags = {
    Name = "aws-infra-01-project-log-group"
  }
}


resource "aws_ecs_task_definition" "backend" {
  family                   = var.backend_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "1024"
  memory                  = "2048"
  execution_role_arn      = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "spring-be"
      image     = var.backend_image_uri
      portMappings = [{
        containerPort = 8080
        hostPort      = 8080
      }]
      environment = [
        {
          name  = "MONGO_URL"
          value = var.mongo_url
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = "ap-southeast-1"
          awslogs-stream-prefix = "ecs"
        }
      }

    }
  ])
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = var.frontend_task_family
  requires_compatibilities = ["FARGATE"]
  network_mode            = "awsvpc"
  cpu                     = "1024"
  memory                  = "2048"
  execution_role_arn      = aws_iam_role.task_execution_role.arn
  task_role_arn           = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "reactjs-fe"
      image     = var.frontend_image_uri
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
      }]
      environment = [
        {
          name  = "REACT_APP_API_URL"
          value = var.api_url
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = var.backend_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_tg_arn
    container_name   = "spring-be"
    container_port   = 8080
  }

  depends_on = [aws_ecs_task_definition.backend]
}

resource "aws_ecs_service" "frontend" {
  name            = var.frontend_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = var.private_subnet_ids
    security_groups = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_tg_arn
    container_name   = "reactjs-fe"
    container_port   = 3000
  }

  depends_on = [aws_ecs_task_definition.frontend]
}
