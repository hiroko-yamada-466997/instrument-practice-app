output "vpc_id" {
  value = module.network.vpc_id
}
output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}
output "app_subnet_ids" {
  value = module.network.app_subnet_ids
}
output "db_subnet_ids" {
  value = module.network.db_subnet_ids
}
output "app_route_table_ids" {
  value = module.network.app_route_table_ids
}
output "alb_security_group_id" {
  value = module.security_groups.alb_security_group_id
}
output "frontend_security_group_id" {
  value = module.security_groups.frontend_security_group_id
}
output "backend_security_group_id" {
  value = module.security_groups.backend_security_group_id
}
output "database_security_group_id" {
  value = module.security_groups.database_security_group_id
}
output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}
output "ecs_execution_role_arn" {
  value = module.iam.ecs_execution_role_arn
}
output "ecs_task_role_arn" {
  value = module.iam.ecs_task_role_arn
}
output "github_actions_role_arn" {
  value = module.iam.github_actions_role_arn
}
output "django_secret_parameter_arn" {
  value = aws_ssm_parameter.django_secret_key.arn
}
output "log_group_names" {
  value = module.monitoring.log_group_names
}
output "alert_topic_arn" {
  value = module.monitoring.alert_topic_arn
}
output "certificate_arn" {
  value = try(aws_acm_certificate.this[0].arn, null)
}
output "route53_zone_id" {
  value = var.route53_zone_id
}
output "domain_name" {
  value = var.domain_name
}
