locals {
  tags = {
    project     = var.project
  }
}




# --- ECR Repository ---
resource "aws_ecr_repository" "moai_repo" {
  name = var.ecr_moai_repo_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
      local.tags,
      {
        Name = var.ecr_moai_repo_name
      }
  )
}

resource "aws_ecr_repository" "aegis_repo" {
  name = var.ecr_aegis_repo_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
      local.tags,
      {
        Name = var.ecr_aegis_repo_name
      }
  )
}

resource "aws_ecr_repository" "valkey_repo" {
  name = var.ecr_valkey_repo_name

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
      local.tags,
      {
        Name = var.ecr_valkey_repo_name
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

# Custom inline policy to allow secrets access
resource "aws_iam_role_policy" "ecs_secrets_access" {
  name = "ecsSecretsAccessPolicy"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = [
          aws_secretsmanager_secret.aegis_secret.arn,
          aws_secretsmanager_secret.moai_secret.arn,
          aws_secretsmanager_secret.valkey_secret.arn
        ]
      }
    ]
  })
}


# Create a CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group_moai" {
  name              = "/ecs/moai"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group_aegis" {
  name              = "/ecs/aegis"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "ecs_log_group_valkey" {
  name              = "/ecs/valkey"
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

resource "aws_service_discovery_service" "moai" {
  name = "moai"
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

resource "aws_service_discovery_service" "aegis" {
  name = "aegis"
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

resource "aws_service_discovery_service" "valkey" {
  name = "valkey"
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


# --- MOAI Service ---

resource "aws_secretsmanager_secret" "moai_secret" {
  name        = "moai/env"
  description = "Environment variables for Moai service"
}


resource "aws_secretsmanager_secret_version" "moai_secret_version" {
  secret_id     = aws_secretsmanager_secret.moai_secret.id
  secret_string = jsonencode({
    RUST_LOG                              = "debug",
    AUTH_PROVIDER                         = "microsoft",
    AUTH_REDIRECT_URL                     = "http://moai-auth-service:10001/auth/callback",
    AUTH_URL                              = "https://login.microsoftonline.com/common/oauth2/v2.0/authorize",
    TOKEN_URL                             = "https://login.microsoftonline.com/common/oauth2/v2.0/token",
    USERINFO_URL                          = "https://graph.microsoft.com/oidc/userinfo",
    POSTGRES_URL                          = "mysql://dbuser:StrongPassword@192.168.1.56:3306/moai_auth",
    AUTH_SCOPE                            = "openid email profile User.Read",
    JWT_AUDIENCE                          = "aegis-api",
    JWT_ISSUER                            = "moai-auth-service",
    REDIS_SESSION_ENABLED                 = "true",
    REDIS_SESSION_PREFIX                  = "moai_auth_session:",
    REDIS_SESSION_TTL                     = "1",
    AEGIS_SERVICE_URL                     = "http://aegis-service:10005",
    AEGIS_SERVICE_ENABLED                 = "true",
    TEST_USER_ID                          = "00000000-0000-0000-0000-000000000001",
    DEVELOPMENT_MODE                      = "false",
    DB_MAX_CONNECTIONS                    = "5",
    ADMIN_EMAILS                          = "admin@globalinvest.com,admin@retailbank.com",
    USER_EMAILS                           = "analyst@globalinvest.com,director@globalinvest.com,teller@retailbank.com",
    USER_SYNC_WEBHOOK_ENABLED             = "true",
    USER_SYNC_WEBHOOK_VALIDATE_SIGNATURES = "true",
    HERMES_ENABLED                        = "false",
    HERMES_TOKEN                          = "hermes_token",
    CORS_ALLOWED_ORIGINS                  = "https://192.168.1.56",
    CORS_ALLOW_CREDENTIALS                = "true",
    DATABASE_TYPE                         = "mysql",
    OPENTELEMETRY_ENABLED                 = "false",
    ENV_FILE                              = "/etc/moai/config.env",
    DATABASE_URL                          = "mysql://${var.db_username}:${var.db_password}@${var.rds_endpoint}/moai_auth",
    REDIS_URL                             = "redis://default:valkey-passw0rd@valkey-service:6379",
    AUTH_CLIENT_ID                        = "local-dev-client",
    AUTH_CLIENT_SECRET                    = "a879a79ccb46396b1a0380f54b1f3026814fd491399db3",
    SESSION_SECRET                        = "eICKpNek4XGBEQdgeLZQ24+gvf51C1BLq7OPCcJjH8UKYXq3sicuPRdSE3JM/TFJhKDuqSkkaiSc/ipdREzjHw==",
    AEGIS_API_KEY                         = "aca55d468c82d05c0497bdad052861fe22717f7e42958ad3b0cc1a55b973a1c7",
    ADMIN_PASSWORD_HASH                   = "$2b$10$rRN9aBigVzGzVl9VlmPnSOGYjYRQQIHHLjvQiG7YOoStTQKV1y1Vy",
    USER_PASSWORD_HASH                    = "$2a$14$X4z6XeRVWf9lfT.3Ssfh/u8W6GwWgPQU7u./COhHbiQVz2DIarv.O",
    USER_SYNC_WEBHOOK_SECRET              = "2ef4a3e905b3c33abf247d792324d9051df4996a1d0d917d8942212e9957ef38",
    MOAI_API_KEY                          = "31b68da6a026747862480491e23b7b5c45234441aa451e452a246e949ff32daf"
  })
}

locals {
  moai_secret_map = jsondecode(aws_secretsmanager_secret_version.moai_secret_version.secret_string)

  moai_container_def = [
    {
      name  = "moai_auth_service"
      image = "${aws_ecr_repository.moai_repo.repository_url}:${var.moai_image_tag}"
      portMappings = [{
        containerPort = 8081
        hostPort      = 8081
        protocol      = "tcp"
      }]
      secrets = [
        for key in keys(local.moai_secret_map) : {
          name      = key
          valueFrom = aws_secretsmanager_secret.moai_secret.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/moai"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8081/health || exit 1"]
        interval    = 20
        timeout     = 3
        retries     = 3
        startPeriod = 30
      }
    }
  ]
}



# --- ECS Task Definition - MOAI ---
resource "aws_ecs_task_definition" "moai_task" {
  family                   = "moai"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode(local.moai_container_def)

  tags = merge(
    local.tags,
    {
      Name = "moai"
    }
  )
}


# --- ECS Service MOAI---
resource "aws_ecs_service" "moai_service" {
  name            = "moai_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.moai_task.arn
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
        Name = "moai_ecs_service"
      }
  )
}



# --- AEGIS Service ---

resource "aws_secretsmanager_secret" "aegis_secret" {
  name        = "aegis/env"
  description = "Environment variables for Aegis service"
}

resource "aws_secretsmanager_secret_version" "aegis_secret_version" {
  secret_id     = aws_secretsmanager_secret.aegis_secret.id
  secret_string = jsonencode({
    DB_NAME                  = "aegis",
    DB_SYNCHRONIZE           = "false",
    DB_LOGGING               = "false",
    JWT_EXPIRES_IN           = "1h",
    JWT_AUDIENCE             = "aegis-api",
    JWT_ISSUER               = "moai-auth-service",
    MOAI_AUTH_BASE_URL       = "http://moai-auth-service:10001",
    MOAI_AUTH_CLIENT_ID      = "aegis-service",
    MOAI_AUTH_CLIENT_SECRET  = "eICKpNek4XGBEQdgeLZQ24+gvf51C1BLq7OPCcJjH8UKYXq3sicuPRdSE3JM/TFJhKDuqSkkaiSc/ipdREzjHw==",
    MOAI_API_URL             = "http://moai-auth-service:10001",
    MOAI_API_KEY             = "31b68da6a026747862480491e23b7b5c45234441aa451e452a246e949ff32daf",
    DATABASE_URL             = "mysql://${var.db_username}:${var.db_password}@${var.rds_endpoint}/aegis",
    DEFAULT_TENANT_ID        = "default-entity",
    SERVICE_AUTH_API_KEYS    = "moai-auth-key,test-key",
    SERVICE_AUTH_MTLS_ENABLED = "false",
    SERVICE_AUTH_RATE_LIMIT_MAX = "100",
    SERVICE_AUTH_RATE_LIMIT_WINDOW_MS = "60000",
    VALKEY_HOST              = "valkey-service",
    VALKEY_PORT              = "6379",
    VALKEY_TTL               = "1",
    TPM_SERVICE_URL          = "http://tpm-service:10005",
    WEBHOOK_ENDPOINTS        = "https://example.com/webhook,https://backup.example.com/webhook",
    WEBHOOK_SECRET           = "your-webhook-secret",
    SYNC_MOAI                = "true",
    DB_TYPE                  = "mysql"
  })
}

locals {
  aegis_secret_map = jsondecode(aws_secretsmanager_secret_version.aegis_secret_version.secret_string)

  aegis_container_def = [
    {
      name  = "aegis_service"
      image = "${aws_ecr_repository.aegis_repo.repository_url}:${var.aegis_image_tag}"
      portMappings = [{
        containerPort = 3000
        hostPort      = 3000
        protocol      = "tcp"
      }]
      secrets = [
        for key in keys(local.aegis_secret_map) : {
          name      = key
          valueFrom = "${aws_secretsmanager_secret.aegis_secret.arn}:${key}"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/aegis"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/api/v1/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }
    }
  ]
}



# --- ECS Task Definition - AEGIS ---
resource "aws_ecs_task_definition" "aegis_task" {
  family                   = "aegis"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode(local.aegis_container_def)

  tags = merge(
    local.tags,
    {
      Name = "aegis"
    }
  )
}



# --- ECS Service AEGIS---
resource "aws_ecs_service" "aegis_service" {
  name            = "aegis_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.aegis_task.arn
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
        Name = "aegis_ecs_service"
      }
  )
}

# --- EFS Access Point ---
resource "aws_efs_file_system" "valkey_efs" {
  creation_token = "valkey_efs"

  tags = merge(
      local.tags,
      {
        Name = "valkey_efs"
      }
  )
}

# --- EFS Access Point ---
resource "aws_efs_access_point" "valkey_access_point" {
  file_system_id = aws_efs_file_system.valkey_efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "/valkey-data"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "0755"
    }
  }

  tags = {
    Name = "valkey_access_point"
  }
}

resource "aws_secretsmanager_secret" "valkey_secret" {
  name        = "valkey/env"
  description = "Environment variables for valkey service"
}

resource "aws_secretsmanager_secret_version" "valkey_secret_version" {
  secret_id     = aws_secretsmanager_secret.valkey_secret.id
  secret_string = jsonencode({
    VALKEY_PASSWORD  = "valkey-passw0rd"
  })
}


locals {
  valkey_secret_map = jsondecode(aws_secretsmanager_secret_version.valkey_secret_version.secret_string)

  valkey_container_def = [
    {
      name  = "valkey-service"
      image = "${aws_ecr_repository.valkey_repo.repository_url}:${var.valkey_image_tag}"
      portMappings = [{
        containerPort = 6379
        hostPort      = 6379
        protocol      = "tcp"
      }]
      secrets = [
        for key in keys(local.valkey_secret_map) : {
          name      = key
          valueFrom = aws_secretsmanager_secret.valkey_secret.arn
        }
      ]
      command = [
        "--requirepass", "valkey-passw0rd",
        "--dir", "/data",
        "--dbfilename", "dump.rdb"
      ]
      mountPoints = [{
        containerPath = "/data"
        sourceVolume  = "valkey-data"
        readOnly      = false
      }]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/valkey"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "valkey-cli -a $VALKEY_PASSWORD PING"]
        interval    = 10
        timeout     = 5
        retries     = 6
        startPeriod = 15
      }
    }
  ]
}



# --- ECS Task Definition for Valkey ---
resource "aws_ecs_task_definition" "valkey_task" {
  family                   = "valkey"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  volume {
    name = "valkey-data"
    efs_volume_configuration {
      file_system_id          = aws_efs_file_system.valkey_efs.id
      transit_encryption      = "ENABLED"
      authorization_config {
        access_point_id = aws_efs_access_point.valkey_access_point.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode(local.valkey_container_def)

  tags = {
    Name = "valkey-task"
  }
}


# --- ECS Service for Valkey ---
resource "aws_ecs_service" "valkey_service" {
  name            = "valkey_ecs_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.valkey_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.app_security_group_id]
    assign_public_ip = false
  }

  tags = {
    Name = "valkey_ecs_service"
  }
}

