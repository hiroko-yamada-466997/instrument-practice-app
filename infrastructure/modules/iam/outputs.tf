output "ecs_execution_role_arn" {
  value = aws_iam_role.execution.arn
}
output "ecs_task_role_arn" {
  value = aws_iam_role.task.arn
}
output "github_actions_role_arn" {
  value = aws_iam_role.github.arn
}
output "github_oidc_provider_arn" {
  value = local.oidc_provider_arn
}
