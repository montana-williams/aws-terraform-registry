# -----------------------------------------------
# CloudWatch — Monitoring and Observability
# -----------------------------------------------
# Metrics, alarms, and logs for your infrastructure.
# Build after SNS — alarms need a topic to notify.
# -----------------------------------------------

# -----------------------------------------------
# Log Group
# -----------------------------------------------
# Container for logs from one service.
# Always set retention — never leave at Never Expire.
# -----------------------------------------------
resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/lambda/main"            # FILL IN: e.g. "/aws/lambda/finflow-processor"
                                                    # Convention: /aws/<service>/<function-name>
  retention_in_days = 30                            # FILL IN: how long to keep logs
                                                    # 7 — dev, 30 — standard prod, 90 — compliance

  tags = {
    Name        = "main-log-group"                  # FILL IN: e.g. "finflow-processor-logs"
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# Lambda Error Alarm
# -----------------------------------------------
# Fires when Lambda throws any errors.
# Even one error in production is worth knowing about.
# -----------------------------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "main-lambda-errors"        # FILL IN: e.g. "finflow-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1                           # FILL IN: number of periods to evaluate
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60                          # FILL IN: seconds per evaluation period
  statistic           = "Sum"
  threshold           = 0                           # Fire on any error
  alarm_description   = "Lambda function is throwing errors"

  dimensions = {
    FunctionName = var.lambda_function_name         # FILL IN: e.g. module.serverless.function_name
  }

  alarm_actions = [var.sns_topic_arn]               # FILL IN: e.g. module.sns.topic_arn
  ok_actions    = [var.sns_topic_arn]               # Notify when alarm clears too

  tags = {
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# DLQ Depth Alarm
# -----------------------------------------------
# Fires when messages land in the Dead Letter Queue.
# Any DLQ message means something failed to process.
# -----------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dlq_depth" {
  alarm_name          = "main-dlq-depth"            # FILL IN: e.g. "finflow-dlq-depth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0                           # Fire on any DLQ message
  alarm_description   = "Messages are landing in the Dead Letter Queue"

  dimensions = {
    QueueName = var.dlq_name                        # FILL IN: e.g. module.messaging.dlq_name
  }

  alarm_actions = [var.sns_topic_arn]               # FILL IN: e.g. module.sns.topic_arn

  tags = {
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# RDS CPU Alarm
# -----------------------------------------------
# Fires when RDS CPU stays high.
# Sustained high CPU usually means missing indexes
# or a runaway query.
# -----------------------------------------------
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "main-rds-cpu"              # FILL IN: e.g. "finflow-rds-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2                           # Two periods avoids false alarms on spikes
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300                         # 5 minute periods for RDS
  statistic           = "Average"
  threshold           = 80                          # FILL IN: percentage — 80 is a reasonable default
  alarm_description   = "RDS CPU utilization is high"

  dimensions = {
    DBInstanceIdentifier = var.db_instance_id       # FILL IN: e.g. module.storage.db_instance_id
  }

  alarm_actions = [var.sns_topic_arn]               # FILL IN: e.g. module.sns.topic_arn

  tags = {
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "log_group_name" {
  description = "The name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.main.name
}

output "log_group_arn" {
  description = "The ARN of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.main.arn
}
