output "log_group_names" {
  value = { for name, group in aws_cloudwatch_log_group.this : name => group.name
  }
}
output "alert_topic_arn" {
  value = try(aws_sns_topic.alerts[0].arn, null)
}
