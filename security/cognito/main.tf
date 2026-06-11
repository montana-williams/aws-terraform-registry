# -----------------------------------------------
# Cognito — User Pool and App Client
# -----------------------------------------------
# Managed authentication service.
# Handles sign up, sign in, and JWT issuance.
# API Gateway validates the JWT on every request.
# -----------------------------------------------

# -----------------------------------------------
# User Pool
# -----------------------------------------------
# The directory that stores your users.
# -----------------------------------------------
resource "aws_cognito_user_pool" "main" {
  name = "main-user-pool"                           # FILL IN: e.g. "finflow-user-pool"

  # -----------------------------------------------
  # Login method
  # -----------------------------------------------
  username_attributes      = ["email"]              # FILL IN: email or phone_number
                                                    # Cannot be changed after creation — decide upfront
  auto_verified_attributes = ["email"]              # Sends verification email on sign up

  # -----------------------------------------------
  # Password policy
  # -----------------------------------------------
  password_policy {
    minimum_length    = 8                           # FILL IN: minimum password length
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false                       # FILL IN: set true for stricter security
  }

  # -----------------------------------------------
  # Account recovery
  # -----------------------------------------------
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email_first"
      priority = 1
    }
  }

  tags = {
    Name        = "main-user-pool"                  # FILL IN: e.g. "finflow-user-pool"
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "finflow"
  }
}

# -----------------------------------------------
# App Client
# -----------------------------------------------
# The key your frontend uses to authenticate
# against the User Pool.
# -----------------------------------------------
resource "aws_cognito_user_pool_client" "main" {
  name         = "main-app-client"                  # FILL IN: e.g. "finflow-app-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # -----------------------------------------------
  # Auth flows
  # -----------------------------------------------
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",                     # Standard email + password login
    "ALLOW_REFRESH_TOKEN_AUTH"                      # Allows token refresh without re-login
  ]

  # -----------------------------------------------
  # Security
  # -----------------------------------------------
  prevent_user_existence_errors = "ENABLED"         # Always enable — stops attackers probing
                                                    # whether an email exists in your pool

  # -----------------------------------------------
  # Token expiry
  # -----------------------------------------------
  access_token_validity  = 1                        # FILL IN: hours — how long access tokens last
  id_token_validity      = 1                        # FILL IN: hours
  refresh_token_validity = 30                       # FILL IN: days — how long refresh tokens last

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool — used for API Gateway JWT authorizer"
  value       = aws_cognito_user_pool.main.arn
}

output "app_client_id" {
  description = "The App Client ID — used by your frontend to authenticate"
  value       = aws_cognito_user_pool_client.main.id
}
