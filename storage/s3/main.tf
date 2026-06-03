# -----------------------------------------------
# S3 — Simple Storage Service
# -----------------------------------------------
# Object storage for files, backups, logs,
# static assets, and anything you store and
# retrieve whole rather than edit in place.
# -----------------------------------------------

# -----------------------------------------------
# S3 Bucket
# -----------------------------------------------
resource "aws_s3_bucket" "main" {
  bucket = "your-project-bucket-name"               # FILL IN: globally unique name across all of AWS
                                                    # e.g. "medbridge-patient-files-prod-2024"
                                                    # tip: include project + environment + random suffix

  tags = {
    Name        = "main-bucket"                    # FILL IN: e.g. "medbridge-patient-files"
    Environment = "dev"                            # FILL IN: dev / staging / prod
    Project     = "your-project-name"              # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Block Public Access
# -----------------------------------------------
# Keeps the bucket private — override only if
# hosting a static website
# -----------------------------------------------
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------
# Versioning
# -----------------------------------------------
# Keeps every version of every object.
# Pair with lifecycle policy to control costs.
# -----------------------------------------------
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"                             # FILL IN: Enabled / Suspended
                                                   # Enable on any bucket holding important data
  }
}

# -----------------------------------------------
# Encryption
# -----------------------------------------------
# Server side encryption at rest.
# Required for HIPAA and PCI-DSS.
# -----------------------------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"                     # AES256 = S3 managed keys (free)
                                                   # aws:kms = KMS managed keys (more control, costs more)
    }
  }
}

# -----------------------------------------------
# Lifecycle Policy
# -----------------------------------------------
# Automatically moves objects to cheaper storage
# tiers as they age. Pair with versioning.
# -----------------------------------------------
resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "transition-to-cheaper-storage"
    status = "Enabled"

    transition {
      days          = 30                           # FILL IN: days before moving to Standard-IA
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90                           # FILL IN: days before moving to Glacier
      storage_class = "GLACIER"
    }

    expiration {
      days = 365                                   # FILL IN: days before deleting object entirely
                                                   # Remove this block if you want to keep forever
    }

    # Expire old versions to control versioning costs
    noncurrent_version_expiration {
      noncurrent_days = 30                         # FILL IN: days to keep old versions
    }
  }
}

# -----------------------------------------------
# Bucket Policy
# -----------------------------------------------
# Controls what services and principals can
# access this bucket. Modify to match your needs.
# -----------------------------------------------
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowAppAccess"
        Effect    = "Allow"
        Principal = {
          AWS = var.app_role_arn                   # FILL IN: IAM role ARN of your application
                                                   # e.g. module.iam.app_role_arn
        }
        Action = [
          "s3:GetObject",                          # Read objects
          "s3:PutObject",                          # Write objects
          "s3:DeleteObject"                        # Delete objects — remove if app shouldn't delete
        ]
        Resource = "${aws_s3_bucket.main.arn}/*"   # All objects in the bucket
      }
    ]
  })
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.main.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.main.arn
}
