# -----------------------------------------------
# DynamoDB
# -----------------------------------------------
# Managed NoSQL database. Scales automatically.
# Design your primary key carefully — it cannot
# be changed after the table is created.
# -----------------------------------------------

# -----------------------------------------------
# DynamoDB Table
# -----------------------------------------------
resource "aws_dynamodb_table" "main" {
  name         = "main-table"                      # FILL IN: e.g. "medbridge-patients"
  billing_mode = "PAY_PER_REQUEST"                 # FILL IN: PAY_PER_REQUEST (on-demand) or PROVISIONED
                                                   # PAY_PER_REQUEST — dev and unpredictable traffic
                                                   # PROVISIONED — production with consistent traffic

  # -----------------------------------------------
  # Primary Key
  # -----------------------------------------------
  hash_key  = "id"                                 # FILL IN: your partition key attribute name
                                                   # e.g. "job_id", "user_id", "order_id"
  range_key = "created_at"                         # FILL IN: sort key — remove this line if not needed
                                                   # e.g. "created_at", "status", "timestamp"

  # -----------------------------------------------
  # Attributes
  # -----------------------------------------------
  # Only define attributes used in keys and indexes
  # DynamoDB is schemaless — don't define every attribute
  # -----------------------------------------------
  attribute {
    name = "id"                                    # FILL IN: must match hash_key above
    type = "S"                                     # S = String, N = Number, B = Binary
  }

  attribute {
    name = "created_at"                            # FILL IN: must match range_key above
    type = "S"                                     # Remove if no range_key
  }

  # -----------------------------------------------
  # Provisioned Capacity (only if PROVISIONED mode)
  # -----------------------------------------------
  # Remove these if using PAY_PER_REQUEST
  # -----------------------------------------------
  # read_capacity  = 5                             # FILL IN: read capacity units
  # write_capacity = 5                             # FILL IN: write capacity units

  # -----------------------------------------------
  # DynamoDB Streams
  # -----------------------------------------------
  stream_enabled   = true                          # FILL IN: true to enable streams
  stream_view_type = "NEW_AND_OLD_IMAGES"          # FILL IN: what data to capture
                                                   # NEW_IMAGE — item after change
                                                   # OLD_IMAGE — item before change
                                                   # NEW_AND_OLD_IMAGES — both (most common)
                                                   # KEYS_ONLY — only the key attributes

  # -----------------------------------------------
  # TTL — Auto delete expired items
  # -----------------------------------------------
  ttl {
    attribute_name = "expires_at"                  # FILL IN: attribute name storing expiry timestamp
    enabled        = true                          # Set false if you don't need auto expiry
  }

  # -----------------------------------------------
  # Point in Time Recovery
  # -----------------------------------------------
  # Lets you restore the table to any point in
  # the last 35 days — enable in production
  # -----------------------------------------------
  point_in_time_recovery {
    enabled = true
  }

  tags = {
    Name        = "main-table"                    # FILL IN: e.g. "medbridge-patients"
    Environment = "dev"                           # FILL IN: dev / staging / prod
    Project     = "your-project-name"             # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Global Secondary Index (optional)
# -----------------------------------------------
# Lets you query on non-primary key attributes
# Only create indexes you actually query against
# -----------------------------------------------
# Add inside the aws_dynamodb_table resource block:
#
# global_secondary_index {
#   name            = "status-index"              # FILL IN: index name
#   hash_key        = "status"                    # FILL IN: GSI partition key
#   range_key       = "created_at"               # FILL IN: GSI sort key (optional)
#   projection_type = "ALL"                       # ALL / KEYS_ONLY / INCLUDE
# }
#
# attribute {
#   name = "status"                               # FILL IN: must match GSI hash_key
#   type = "S"
# }

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "table_name" {
  description = "The name of the DynamoDB table"
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "The ARN of the DynamoDB table"
  value       = aws_dynamodb_table.main.arn
}

output "stream_arn" {
  description = "The ARN of the DynamoDB stream"
  value       = aws_dynamodb_table.main.stream_arn
}
