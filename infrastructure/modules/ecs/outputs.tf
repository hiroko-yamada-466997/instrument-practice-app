output "cluster_name" {
  value = aws_ecs_cluster.this.name
}
output "backend_task_definition_arn" {
  value = aws_ecs_task_definition.backend.arn
}
output "frontend_service_name" {
  value = aws_ecs_service.frontend.name
}
output "backend_service_name" {
  value = aws_ecs_service.backend.name
}
