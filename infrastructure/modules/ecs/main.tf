locals {
  common_environment = [
    {
      name = "POSTGRES_DB", value = var.database_name
    },
    {
      name = "POSTGRES_HOST", value = var.database_host
    },
    {
      name = "POSTGRES_PORT", value = tostring(var.database_port)
    },
    {
      name = "DJANGO_DEBUG", value = "false"
    },
    {
      name = "DJANGO_ALLOWED_HOSTS", value = var.application_hostname

    }
  ]
}

resource "aws_ecs_cluster" "this" {
  name = var.name
  setting {
    name  = "containerInsights"
    value = "enabled"

  }
  tags = var.tags
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.name}-frontend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  runtime_platform {
    cpu_architecture        = var.cpu_architecture
    operating_system_family = "LINUX"

  }
  container_definitions = jsonencode([{
    name = "frontend", image = var.frontend_image, essential = true, portMappings = [{
      containerPort = 3000, protocol = "tcp"
      }], environment = [{
      name = "NODE_ENV", value = "production"
      }], logConfiguration = {
      logDriver = "awslogs", options = { "awslogs-group" = var.frontend_log_group, "awslogs-region" = var.region, "awslogs-stream-prefix" = "frontend"
      }
    }
  }])
  tags = var.tags
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.name}-backend"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
  runtime_platform {
    cpu_architecture        = var.cpu_architecture
    operating_system_family = "LINUX"

  }
  container_definitions = jsonencode([{
    name = "backend", image = var.backend_image, essential = true, command = ["gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:8000"], portMappings = [{
      containerPort = 8000, protocol = "tcp"
      }], environment = local.common_environment, secrets = [{
      name = "DJANGO_SECRET_KEY", valueFrom = var.django_secret_parameter_arn
      }, {
      name = "POSTGRES_USER", valueFrom = "${var.database_secret_arn}:username::"
      }, {
      name = "POSTGRES_PASSWORD", valueFrom = "${var.database_secret_arn}:password::"
      }], logConfiguration = {
      logDriver = "awslogs", options = { "awslogs-group" = var.backend_log_group, "awslogs-region" = var.region, "awslogs-stream-prefix" = "backend"
      }
    }
  }])
  tags = var.tags
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.frontend_security_group_id]
    assign_public_ip = false

  }
  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 3000

  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true

  }
  tags = var.tags
}

resource "aws_ecs_service" "backend" {
  name            = "backend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.backend_security_group_id]
    assign_public_ip = false

  }
  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = 8000

  }
  deployment_circuit_breaker {
    enable   = true
    rollback = true

  }
  tags = var.tags
}
