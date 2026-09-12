resource "aws_cloudwatch_log_group" "this" {
  for_each          = toset(var.log_groups)
  name              = "/ecs/${var.name}/${each.value}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

resource "aws_sns_topic" "alerts" {
  count = var.create_alert_topic ? 1 : 0
  name  = "${var.name}-alerts"
  tags  = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  count     = var.create_alert_topic && var.alert_email != null ? 1 : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_event_rule" "acm_expiring" {
  count       = var.create_alert_topic ? 1 : 0
  name        = "${var.name}-acm-expiring"
  description = "ACM certificate approaching expiry"
  event_pattern = jsonencode({
    source = ["aws.acm"], detail-type = ["ACM Certificate Approaching Expiration"]
  })
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "acm_expiring" {
  count = var.create_alert_topic ? 1 : 0
  rule  = aws_cloudwatch_event_rule.acm_expiring[0].name
  arn   = aws_sns_topic.alerts[0].arn
}

data "aws_iam_policy_document" "sns_events" {
  count = var.create_alert_topic ? 1 : 0
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts[0].arn]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]

    }


  }
}

resource "aws_sns_topic_policy" "events" {
  count  = var.create_alert_topic ? 1 : 0
  arn    = aws_sns_topic.alerts[0].arn
  policy = data.aws_iam_policy_document.sns_events[0].json
}
