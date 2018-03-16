resource "aws_cloudwatch_event_rule" "generate_website_event" {
  name                = "generate_${replace(var.domain, ".", "-")}"
  description         = "Fires every 60 minutes"
  schedule_expression = "rate(60 minutes)"
}

# the event target
resource "aws_cloudwatch_event_target" "generate_website_event_target" {
  rule      = "${aws_cloudwatch_event_rule.generate_website_event.name}"
  target_id = "generate_website"
  arn       = "${aws_lambda_function.build.arn}"
}
