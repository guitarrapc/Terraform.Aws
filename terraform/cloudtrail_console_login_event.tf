# AWS Console Login Capture
locals {
    aws_console_login_capture_name = "aws-console-logins"
    sns_event_target_id = "SendToSNS"
}

# sns
resource "aws_sns_topic" "aws_console_logins" {
  name = "${local.aws_console_login_capture_name}"
}

# cloudwatch events
resource "aws_cloudwatch_event_rule" "aws_console_logins" {
  name        = "${local.aws_console_login_capture_name}"
  description = "Capture each AWS Console Sign In"

  event_pattern = <<PATTERN
{
  "detail-type": [
    "AWS Console Sign In via CloudTrail"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = "${aws_cloudwatch_event_rule.aws_console_logins.name}"
  target_id = "${local.sns_event_target_id}"
  arn       = "${aws_sns_topic.aws_console_logins.arn}"
}