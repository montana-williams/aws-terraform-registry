# -----------------------------------------------
# IAM — Identity and Access Management
# -----------------------------------------------
# Controls who and what can access your AWS resources.
# Always follow least privilege — only grant the
# specific actions needed on specific resources.
# -----------------------------------------------

# -----------------------------------------------
# IAM Role for a Service (e.g. Lambda)
# -----------------------------------------------
# Services assume roles — never use access keys
# -----------------------------------------------
resource "aws_iam_role" "app_role" {
  name = "app-service-role"                        # FILL IN: e.g. "medbridge-lambda-role"

  # Trust policy — who can assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"           # FILL IN: the service assuming this role
                                                   # lambda.amazonaws.com — Lambda
                                                   # ec2.amazonaws.com — EC2
                                                   # ecs-tasks.amazonaws.com — ECS
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name        = "app-service-role"              # FILL IN: e.g. "medbridge-lambda-role"
    Environment = "dev"                           # FILL IN: dev / staging / prod
    Project     = "your-project-name"             # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Least Privilege Policy
# -----------------------------------------------
# Only grant the specific actions needed on
# specific resources — nothing more
# -----------------------------------------------
resource "aws_iam_role_policy" "app_policy" {
  name = "app-least-privilege-policy"
  role = aws_iam_role.app_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject"                          # FILL IN: only the actions needed
                                                  # s3:GetObject — read files
                                                  # s3:PutObject — write files
                                                  # s3:DeleteObject — delete files
                                                  # Never use s3:* in production
        ]
        Resource = "arn:aws:s3:::your-bucket/*"   # FILL IN: specific bucket ARN
                                                  # Never use * for sensitive resources
      },
      {
        Sid    = "DynamoDBWriteAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",                     # FILL IN: only the actions needed
          "dynamodb:GetItem"                      # dynamodb:PutItem — write
                                                  # dynamodb:GetItem — read single item
                                                  # dynamodb:Query — query by key
                                                  # dynamodb:Scan — full table scan (avoid)
                                                  # dynamodb:DeleteItem — delete
        ]
        Resource = "arn:aws:dynamodb:us-east-1:ACCOUNT_ID:table/your-table"
                                                  # FILL IN: specific table ARN
                                                  # Replace ACCOUNT_ID and table name
      }
    ]
  })
}

# -----------------------------------------------
# CloudWatch Logs Policy
# -----------------------------------------------
# Attach to any Lambda role so it can write logs
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# -----------------------------------------------
# IAM Group (for human users)
# -----------------------------------------------
# Assign permissions to groups not individuals
# -----------------------------------------------
resource "aws_iam_group" "developers" {
  name = "developers"                             # FILL IN: e.g. "developers", "ops", "read-only"
}

resource "aws_iam_group_policy" "developer_policy" {
  name  = "developer-policy"
  group = aws_iam_group.developers.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DeveloperAccess"
        Effect = "Allow"
        Action = [
          # FILL IN: actions developers need
          # Example read only access to view resources
          "ec2:Describe*",
          "s3:ListBucket",
          "s3:GetObject",
          "logs:GetLogEvents",
          "logs:DescribeLogGroups"
        ]
        Resource = "*"                            # FILL IN: scope to specific resources where possible
      }
    ]
  })
}

# -----------------------------------------------
# IAM User (for a human)
# -----------------------------------------------
# Always add to a group — never assign permissions
# directly to a user
# -----------------------------------------------
resource "aws_iam_user" "developer" {
  name = "developer-name"                         # FILL IN: e.g. "montana.williams"

  tags = {
    Name        = "developer-name"
    Environment = "dev"
    Project     = "your-project-name"
  }
}

resource "aws_iam_user_group_membership" "developer" {
  user   = aws_iam_user.developer.name
  groups = [aws_iam_group.developers.name]        # Always add users to groups
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "app_role_arn" {
  description = "The ARN of the application service role"
  value       = aws_iam_role.app_role.arn
}

output "app_role_name" {
  description = "The name of the application service role"
  value       = aws_iam_role.app_role.name
}
