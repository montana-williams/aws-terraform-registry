# -----------------------------------------------
# CloudTrail — API Audit Logging
# -----------------------------------------------
# Records every API call in your AWS account.
# Delivers logs to S3 for long term retention.
# Required for HIPAA, PCI-DSS, and most compliance frameworks.
# -----------------------------------------------

# -----------------------------------------------
# S3 Bucket
# -----------------------------------------------
# Where CloudTrail delivers log files.
# Must have a specific bucket policy — CloudTrail
# will fail silently without it.
# -----------------------------------------------
resource "aws_s3_bucket" "cloudtrail" {
  bucket        = "main-cloudtrail-logs"            # FILL IN: e.g. "finflow-cloudtrail-logs"
                                                    # Must be globally unique across all AWS accounts
  force_destroy = true                              # FILL IN: set false in production
                                                    # Prevents accidental deletion of audit logs

  tags = {
    Name        = "main-cloudtrail-logs"            # FILL IN: e.g. "finflow-cloudtrail-logs"
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# S3 Bucket Policy
# -----------------------------------------------
# Allows CloudTrail to write logs to the bucket.
# This exact policy structure is required —
# CloudTrail will not deliver logs without it.
# -----------------------------------------------
resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${var.aws_account_id}/*"
                                                    # FILL IN: var.aws_account_id — your AWS account ID
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# -----------------------------------------------
# CloudTrail
# -----------------------------------------------
resource "aws_cloudtrail" "main" {
  name                          = "main-trail"      # FILL IN: e.g. "finflow-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true              # Captures IAM and STS events which are global
  is_multi_region_trail         = true              # Best practice — covers all regions in one trail
  enable_log_file_validation    = true              # Detects if logs are tampered with
                                                    # Required for most compliance frameworks

  # -----------------------------------------------
  # CloudWatch Logs integration (optional)
  # -----------------------------------------------
  # Uncomment to stream CloudTrail events to
  # CloudWatch Logs for real time alerting.
  # -----------------------------------------------
  # cloud_watch_logs_group_arn = "${var.cloudwatch_log_group_arn}:*"
                                                    # FILL IN: e.g. module.cloudwatch.log_group_arn
  # cloud_watch_logs_role_arn  = var.cloudtrail_role_arn
                                                    # FILL IN: IAM role that allows CloudTrail
                                                    # to write to CloudWatch Logs

  depends_on = [aws_s3_bucket_policy.cloudtrail]   # Bucket policy must exist before trail is created

  tags = {
    Name        = "main-trail"                      # FILL IN: e.g. "finflow-trail"
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "trail_arn" {
  description = "The ARN of the CloudTrail trail"
  value       = aws_cloudtrail.main.arn
}

output "s3_bucket_name" {
  description = "The S3 bucket where CloudTrail logs are delivered"
  value       = aws_s3_bucket.cloudtrail.id
}
