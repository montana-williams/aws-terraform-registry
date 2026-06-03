# -----------------------------------------------
# SQS — Simple Queue Service
# -----------------------------------------------
# Decouples services by holding messages in a queue
# until a consumer is ready to process them.
# Always pair with a Dead Letter Queue in production.
# -----------------------------------------------

# -----------------------------------------------
# Dead Letter Queue
# -----------------------------------------------
# Receives messages that fail processing more than
# maxReceiveCount times. Create this first.
# -----------------------------------------------
resource "aws_sqs_queue" "dlq" {
  name                      = "main-queue-dlq"              # FILL IN: e.g. "medbridge-jobs-dlq"
  message_retention_seconds = 1209600                       # 14 days — max retention for DLQ
                                                            # gives you time to investigate failures

  tags = {
    Name        = "main-queue-dlq"
    Environment = "dev"                                     # FILL IN: dev / staging / prod
    Project     = "your-project-name"                       # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Main Queue
# -----------------------------------------------
resource "aws_sqs_queue" "main" {
  name                       = "main-queue"                 # FILL IN: e.g. "medbridge-jobs"
                                                            # For FIFO add .fifo suffix e.g. "jobs.fifo"
  visibility_timeout_seconds = 180                          # FILL IN: set to 6x your Lambda timeout
                                                            # Lambda timeout 30s → visibility timeout 180s
  message_retention_seconds  = 345600                       # FILL IN: seconds to retain messages
                                                            # 345600 = 4 days (default)
                                                            # 1209600 = 14 days (max)
  receive_wait_time_seconds  = 20                           # Long polling — always use 20
                                                            # Waits up to 20s for messages, cheaper than 0

  # -----------------------------------------------
  # Dead Letter Queue config
  # -----------------------------------------------
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3                                 # FILL IN: failures before moving to DLQ
                                                            # 3 is a reasonable default
  })

  tags = {
    Name        = "main-queue"                             # FILL IN: e.g. "medbridge-jobs"
    Environment = "dev"                                    # FILL IN: dev / staging / prod
    Project     = "your-project-name"                      # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Queue Policy
# -----------------------------------------------
# Controls what services can send messages to
# this queue. Least privilege — only allow
# the services that actually need to send.
# -----------------------------------------------
resource "aws_sqs_queue_policy" "main" {
  queue_url = aws_sqs_queue.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaSend"
        Effect = "Allow"
        Principal = {
          AWS = var.lambda_role_arn                        # FILL IN: e.g. module.lambda.lambda_role_arn
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.main.arn
      }
    ]
  })
}

# -----------------------------------------------
# Lambda Event Source Mapping
# -----------------------------------------------
# Triggers Lambda when messages land in the queue
# -----------------------------------------------
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = var.lambda_arn                        # FILL IN: e.g. module.lambda.lambda_arn
  batch_size       = 10                                    # FILL IN: messages per Lambda invocation
                                                           # Lower = faster per message processing
                                                           # Higher = more efficient for bulk processing
  enabled          = true
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "queue_url" {
  description = "The URL of the SQS queue"
  value       = aws_sqs_queue.main.url
}

output "queue_arn" {
  description = "The ARN of the SQS queue"
  value       = aws_sqs_queue.main.arn
}

output "dlq_arn" {
  description = "The ARN of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.arn
}
