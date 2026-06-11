# -----------------------------------------------
# SNS — Simple Notification Service
# -----------------------------------------------
# Push notification service.
# Broadcasts messages immediately to all subscribers.
# Use for alerting and fan out patterns.
# -----------------------------------------------

# -----------------------------------------------
# SNS Topic
# -----------------------------------------------
# The channel messages are published to.
# Publishers send here, subscribers listen here.
# -----------------------------------------------
resource "aws_sns_topic" "main" {
  name = "main-notifications"                       # FILL IN: e.g. "finflow-alerts"

  tags = {
    Name        = "main-notifications"              # FILL IN: e.g. "finflow-alerts"
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# Email Subscription
# -----------------------------------------------
# Sends SNS messages to an email address.
# Requires manual confirmation from the recipient
# before messages are delivered.
# -----------------------------------------------
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"              # FILL IN: ops team email address
                                                    # Recipient must confirm before receiving messages
}

# -----------------------------------------------
# SQS Subscription (fan out pattern)
# -----------------------------------------------
# Delivers SNS messages to an SQS queue.
# Use when you need durability — messages sit
# in the queue if the consumer is temporarily down.
# -----------------------------------------------
# resource "aws_sns_topic_subscription" "sqs" {
#   topic_arn = aws_sns_topic.main.arn
#   protocol  = "sqs"
#   endpoint  = var.sqs_queue_arn                   # FILL IN: e.g. module.sqs.queue_arn
# }

# -----------------------------------------------
# Lambda Subscription
# -----------------------------------------------
# Triggers a Lambda function on every message.
# Lambda must have a resource policy allowing
# SNS to invoke it.
# -----------------------------------------------
# resource "aws_sns_topic_subscription" "lambda" {
#   topic_arn = aws_sns_topic.main.arn
#   protocol  = "lambda"
#   endpoint  = var.lambda_arn                      # FILL IN: e.g. module.serverless.lambda_arn
# }

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "topic_arn" {
  description = "The ARN of the SNS topic — used by CloudWatch alarms and other publishers"
  value       = aws_sns_topic.main.arn
}

output "topic_name" {
  description = "The name of the SNS topic"
  value       = aws_sns_topic.main.name
}
