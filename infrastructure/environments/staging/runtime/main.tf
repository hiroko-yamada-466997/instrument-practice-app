locals {
  name = "instrument-practice-staging"
  tags = {
    Project = "instrument-practice-app", Environment = "staging", ManagedBy = "terraform"

  }
  foundation = data.terraform_remote_state.foundation.outputs
}

data "terraform_remote_state" "foundation" {
  backend = "local"
  config = {
    path = var.foundation_state_path

  }
}

check "foundation_https" {
  assert {
    condition     = local.foundation.certificate_arn != null && local.foundation.domain_name != null
    error_message = "Foundation must provide an ACM certificate and staging domain before Runtime can be planned."


  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(local.tags, {
    Name = "${local.name}-nat"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = local.foundation.public_subnet_ids[0]
  tags = merge(local.tags, {
    Name = "${local.name}-nat"
  })
}

resource "aws_route" "app_internet" {
  for_each               = toset(local.foundation.app_route_table_ids)
  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

module "alb" {
  source            = "../../../modules/alb"
  name              = local.name
  vpc_id            = local.foundation.vpc_id
  subnet_ids        = local.foundation.public_subnet_ids
  security_group_id = local.foundation.alb_security_group_id
  certificate_arn   = local.foundation.certificate_arn
  tags              = local.tags
}

module "rds" {
  source                = "../../../modules/rds"
  name                  = local.name
  subnet_ids            = local.foundation.db_subnet_ids
  security_group_id     = local.foundation.database_security_group_id
  engine_version        = var.postgres_engine_version
  instance_class        = var.db_instance_class
  allocated_storage     = 20
  max_allocated_storage = 100
  database_name         = var.database_name
  master_username       = var.master_username
  tags                  = local.tags
}

module "ecs" {
  source                      = "../../../modules/ecs"
  name                        = local.name
  region                      = var.aws_region
  subnet_ids                  = local.foundation.app_subnet_ids
  frontend_security_group_id  = local.foundation.frontend_security_group_id
  backend_security_group_id   = local.foundation.backend_security_group_id
  frontend_target_group_arn   = module.alb.frontend_target_group_arn
  backend_target_group_arn    = module.alb.backend_target_group_arn
  execution_role_arn          = local.foundation.ecs_execution_role_arn
  task_role_arn               = local.foundation.ecs_task_role_arn
  frontend_image              = "${local.foundation.ecr_repository_urls.frontend}:${var.image_tag}"
  backend_image               = "${local.foundation.ecr_repository_urls.backend}:${var.image_tag}"
  frontend_log_group          = local.foundation.log_group_names.frontend
  backend_log_group           = local.foundation.log_group_names.backend
  database_name               = var.database_name
  database_host               = module.rds.address
  database_port               = module.rds.port
  database_secret_arn         = module.rds.master_user_secret_arn
  django_secret_parameter_arn = local.foundation.django_secret_parameter_arn
  application_hostname        = local.foundation.domain_name
  cpu_architecture            = var.cpu_architecture
  desired_count               = var.desired_count
  tags                        = local.tags
  depends_on                  = [aws_route.app_internet]
}

resource "aws_route53_record" "application" {
  count   = local.foundation.route53_zone_id == null ? 0 : 1
  zone_id = local.foundation.route53_zone_id
  name    = local.foundation.domain_name
  type    = "A"
  alias {
    name                   = module.alb.dns_name
    zone_id                = module.alb.zone_id
    evaluate_target_health = true

  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name  = "${local.name}-alb-5xx"
  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  dimensions = {
    LoadBalancer = module.alb.arn_suffix

  }
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = compact([local.foundation.alert_topic_arn])
  tags                = local.tags
}

resource "aws_cloudwatch_metric_alarm" "backend_unhealthy" {
  alarm_name  = "${local.name}-backend-unhealthy"
  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  dimensions = {
    LoadBalancer = module.alb.arn_suffix, TargetGroup = module.alb.backend_target_group_arn_suffix

  }
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 2
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = compact([local.foundation.alert_topic_arn])
  tags                = local.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_connections" {
  alarm_name  = "${local.name}-rds-connections"
  namespace   = "AWS/RDS"
  metric_name = "DatabaseConnections"
  dimensions = {
    DBInstanceIdentifier = module.rds.identifier

  }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 50
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  alarm_actions       = compact([local.foundation.alert_topic_arn])
  tags                = local.tags
}
