output "application_url" {
  value = "https://${local.foundation.domain_name}"
}
output "alb_dns_name" {
  value = module.alb.dns_name
}
output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
output "backend_task_definition_arn" {
  value = module.ecs.backend_task_definition_arn
}
output "app_subnet_ids" {
  value = local.foundation.app_subnet_ids
}
output "backend_security_group_id" {
  value = local.foundation.backend_security_group_id
}
output "database_identifier" {
  value = module.rds.identifier
}
