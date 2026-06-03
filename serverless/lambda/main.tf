# -----------------------------------------------
# Lambda
# -----------------------------------------------
# Serverless compute — runs code in response to
# triggers without managing any server infrastructure.
# -----------------------------------------------

# -----------------------------------------------
# IAM Role for Lambda
# -----------------------------------------------
# Lambda assumes this role when it runs.
# Add only the permissions the function actually needs.
# -----------------------------------------------
resource "aws_iam_role" "lambda" {
  name = "lambda-execution-role"                    # FILL IN: e.g. "medbridge-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Basic execution policy — allows Lambda to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# VPC execution policy — required if Lambda runs inside a VPC
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Custom policy — add permissions your function actually needs
resource "aws_iam_role_policy" "lambda_custom" {
  name = "lambda-custom-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # FILL IN: add only what your function needs
        # Example: read from a specific S3 bucket
        Effect = "Allow"
        Action = [
          "s3:GetObject"                           # FILL IN: specific actions needed
        ]
        Resource = "arn:aws:s3:::your-bucket/*"    # FILL IN: specific resource ARN
      }
    ]
  })
}

# -----------------------------------------------
# Lambda Function
# -----------------------------------------------
resource "aws_lambda_function" "main" {
  function_name = "main-function"                   # FILL IN: e.g. "medbridge-processor"
  role          = aws_iam_role.lambda.arn
  runtime       = "python3.11"                      # FILL IN: python3.11 / nodejs18.x / java17 / go1.x
  handler       = "index.handler"                   # FILL IN: filename.function_name
                                                    # e.g. "main.handler" for main.py with handler() function

  filename         = "function.zip"                 # FILL IN: path to your zipped function code
  source_code_hash = filebase64sha256("function.zip") # Triggers redeployment when code changes

  timeout     = 30                                  # FILL IN: seconds, max 900 (15 minutes)
  memory_size = 128                                 # FILL IN: MB of memory — also controls CPU allocation
                                                    # 128MB minimum, 10240MB maximum
                                                    # More memory = more CPU = faster execution

  # -----------------------------------------------
  # VPC Config (optional)
  # -----------------------------------------------
  # Required if Lambda needs to access resources
  # inside your VPC like RDS or ElastiCache
  # -----------------------------------------------
  vpc_config {
    subnet_ids         = var.private_subnet_ids     # FILL IN: e.g. module.vpc.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]         # FILL IN: Lambda security group
  }

  # -----------------------------------------------
  # Environment Variables
  # -----------------------------------------------
  environment {
    variables = {
      DB_HOST     = var.db_endpoint                 # FILL IN: e.g. module.rds.db_endpoint
      BUCKET_NAME = var.bucket_name                 # FILL IN: e.g. module.s3.bucket_name
      ENVIRONMENT = "dev"                           # FILL IN: dev / staging / prod
      # Never put secrets here — use Secrets Manager
    }
  }

  tags = {
    Name        = "main-function"                  # FILL IN: e.g. "medbridge-processor"
    Environment = "dev"                            # FILL IN: dev / staging / prod
    Project     = "your-project-name"              # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------
# Lambda auto creates this but defining it in
# Terraform lets you control retention period
# -----------------------------------------------
resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${aws_lambda_function.main.function_name}"
  retention_in_days = 30                            # FILL IN: days to keep logs
                                                    # 30 is a reasonable default
                                                    # Increase for compliance requirements
}

# -----------------------------------------------
# SQS Trigger (optional)
# -----------------------------------------------
# Uncomment to trigger Lambda from an SQS queue
# -----------------------------------------------
# resource "aws_lambda_event_source_mapping" "sqs" {
#   event_source_arn = var.sqs_queue_arn            # FILL IN: e.g. module.sqs.queue_arn
#   function_name    = aws_lambda_function.main.arn
#   batch_size       = 10                           # FILL IN: messages per Lambda invocation
#   enabled          = true
# }

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "lambda_role_arn" {
  description = "The ARN of the Lambda execution role"
  value       = aws_iam_role.lambda.arn
}
