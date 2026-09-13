output "arn_suffix" {
  value = aws_lb.this.arn_suffix
}
output "dns_name" {
  value = aws_lb.this.dns_name
}
output "zone_id" {
  value = aws_lb.this.zone_id
}
output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend.arn
}
output "backend_target_group_arn" {
  value = aws_lb_target_group.backend.arn
}
output "frontend_target_group_arn_suffix" {
  value = aws_lb_target_group.frontend.arn_suffix
}
output "backend_target_group_arn_suffix" {
  value = aws_lb_target_group.backend.arn_suffix
}
