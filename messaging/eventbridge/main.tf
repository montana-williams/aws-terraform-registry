# -----------------------------------------------
# EventBridge
# -----------------------------------------------
# Event bus that routes events to targets based
# on rules. Use for scheduling, AWS service events,
# and decoupling application services.
# -----------------------------------------------

# -----------------------------------------------
# Custom Event Bus
# -----------------------------------------------
# For your application events — keeps them
# separate from AWS service events on default bus
# -----------------------------------------------
resource "aws_cloudwatch_event_bus" "main" {
  name = "main-event-bus"                          # FILL IN: e.g. "medbridge-events"

  tags = {
    Name        = "main-event-bus"                # FILL IN: e.g. "medbridge-events"
    Environment = "dev"                           # FILL IN: dev / staging / prod
    Project     = "your-project-name"             # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Scheduled Rule
# -----------------------------------------------
# Triggers a target on a schedule — no incoming
# event needed. Use for cron jobs and nightly tasks.
# -----------------------------------------------
resource "aws_cloudwatch_event_rule" "scheduled" {
  name                = "scheduled-job"            # FILL IN: e.g. "nightly-cleanup"
  description         = "Triggers Lambda on a schedule"
  schedule_expression = "rate(1 day)"              # FILL IN: rate or cron expression
                                                   # rate(5 minutes) — every 5 minutes
                                                   # rate(1 hour) — every hour
                                                   # rate(1 day) — every day
                                                   # cron(0 9 * * ? *) — every day at 9am UTC

  tags = {
    Name        = "scheduled-job"
    Environment = "dev"
    Project     = "your-project-name"
  }
}

resource "aws_cloudwatch_event_target" "scheduled_lambda" {
  rule = aws_cloudwatch_event_rule.scheduled.name
  arn  = var.lambda_arn                            # FILL IN: e.g. module.lambda.lambda_arn
}

resource "aws_lambda_permission" "eventbridge_scheduled" {
  statement_id  = "AllowScheduledEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name                  # FILL IN: e.g. module.lambda.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled.arn
}

# -----------------------------------------------
# Pattern Matching Rule
# -----------------------------------------------
# Triggers a target when an event matches a pattern.
# IMPORTANT: Test your pattern in the AWS console
# Event Pattern tester before deploying.
# EventBridge fails silently if pattern doesn't match.
# -----------------------------------------------
resource "aws_cloudwatch_event_rule" "pattern" {
  name           = "job-completed-rule"            # FILL IN: e.g. "order-placed-rule"
  description    = "Triggers when a job completes"
  event_bus_name = aws_cloudwatch_event_bus.main.name

  event_pattern = jsonencode({
    source      = ["my.application"]               # FILL IN: your event source
    detail-type = ["job.completed"]                # FILL IN: your event detail type
                                                   # Must exactly match your published event
                                                   # One typo = silent failure
  })

  tags = {
    Name        = "job-completed-rule"
    Environment = "dev"
    Project     = "your-project-name"
  }
}

resource "aws_cloudwatch_event_target" "pattern_lambda" {
  rule           = aws_cloudwatch_event_rule.pattern.name
  event_bus_name = aws_cloudwatch_event_bus.main.name
  arn            = var.lambda_arn                  # FILL IN: e.g. module.lambda.lambda_arn

  # -----------------------------------------------
  # Dead Letter Queue
  # -----------------------------------------------
  # Captures failed event deliveries so you don't
  # lose events silently in production
  # -----------------------------------------------
  dead_letter_config {
    arn = var.dlq_arn                              # FILL IN: e.g. module.sqs.dlq_arn
  }
}

resource "aws_lambda_permission" "eventbridge_pattern" {
  statement_id  = "AllowPatternEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name                  # FILL IN: e.g. module.lambda.lambda_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pattern.arn
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "event_bus_name" {
  description = "The name of the custom event bus"
  value       = aws_cloudwatch_event_bus.main.name
}

output "event_bus_arn" {
  description = "The ARN of the custom event bus"
  value       = aws_cloudwatch_event_bus.main.arn
}

output "scheduled_rule_arn" {
  description = "The ARN of the scheduled rule"
  value       = aws_cloudwatch_event_rule.scheduled.arn
}
