locals {
  name = "instrument-practice-staging"
  tags = {
    Project = "instrument-practice-app", Environment = "staging", ManagedBy = "terraform"

  }
}

module "network" {
  source         = "../../../modules/network"
  name           = local.name
  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
  app_subnets    = var.app_subnets
  db_subnets     = var.db_subnets
  tags           = local.tags
}

module "security_groups" {
  source = "../../../modules/security-groups"
  name   = local.name
  vpc_id = module.network.vpc_id
  tags   = local.tags
}

module "ecr" {
  source       = "../../../modules/ecr"
  name         = local.name
  repositories = ["frontend", "backend"]
  tags         = local.tags
}

resource "aws_ssm_parameter" "django_secret_key" {
  name        = "/${local.name}/django-secret-key"
  description = "Django secret key for staging"
  type        = "SecureString"
  value       = var.django_secret_key
  tags        = local.tags
}

module "iam" {
  source                      = "../../../modules/iam"
  name                        = local.name
  region                      = var.aws_region
  github_repository           = var.github_repository
  github_subject              = var.github_subject
  create_oidc_provider        = var.create_github_oidc_provider
  existing_oidc_provider_arn  = var.existing_github_oidc_provider_arn
  django_secret_parameter_arn = aws_ssm_parameter.django_secret_key.arn
  ecr_repository_arns         = module.ecr.repository_arns
  tags                        = local.tags
}

module "monitoring" {
  source             = "../../../modules/monitoring"
  name               = local.name
  log_groups         = ["frontend", "backend"]
  log_retention_days = 14
  create_alert_topic = true
  alert_email        = var.alert_email
  tags               = local.tags
}

resource "aws_acm_certificate" "this" {
  count             = var.domain_name == null ? 0 : 1
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true

  }
  tags = local.tags
}

resource "aws_route53_record" "certificate_validation" {
  for_each = var.domain_name != null && var.route53_zone_id != null ? {
    for option in aws_acm_certificate.this[0].domain_validation_options : option.domain_name => {
      name   = option.resource_record_name
      record = option.resource_record_value
      type   = option.resource_record_type


    }

  } : {}
  zone_id         = var.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.record]
  ttl             = 60
  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "this" {
  count                   = var.domain_name != null && var.route53_zone_id != null ? 1 : 0
  certificate_arn         = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}

resource "aws_budgets_budget" "monthly" {
  count        = var.budget_email == null ? 0 : 1
  name         = "${local.name}-monthly"
  budget_type  = "COST"
  limit_amount = "20"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 5
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]

  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 10
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]

  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 20
    threshold_type             = "ABSOLUTE_VALUE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]

  }
}
