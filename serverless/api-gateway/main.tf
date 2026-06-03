# -----------------------------------------------
# API Gateway — HTTP API
# -----------------------------------------------
# Front facing HTTPS endpoint for your serverless
# backend. Sits in front of Lambda and handles
# auth, routing, throttling, and logging.
# Switch to aws_api_gateway_rest_api for REST API
# if you need WAF, API keys, or usage plans.
# -----------------------------------------------

# -----------------------------------------------
# HTTP API
# -----------------------------------------------
resource "aws_apigatewayv2_api" "main" {
  name          = "main-api"                        # FILL IN: e.g. "medbridge-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["https://yourdomain.com"]      # FILL IN: your frontend domain
                                                    # Use ["*"] for dev only — never in production
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = {
    Name        = "main-api"                       # FILL IN: e.g. "medbridge-api"
    Environment = "dev"                            # FILL IN: dev / staging / prod
    Project     = "your-project-name"              # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Cognito Authorizer
# -----------------------------------------------
# Validates JWT tokens against a Cognito user pool
# before requests reach Lambda
# -----------------------------------------------
resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.main.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [var.cognito_client_id]             # FILL IN: Cognito app client ID
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${var.cognito_user_pool_id}"
                                                   # FILL IN: your region and user pool ID
  }
}

# -----------------------------------------------
# Lambda Integration
# -----------------------------------------------
resource "aws_apigatewayv2_integration" "lambda" {
  api_id             = aws_apigatewayv2_api.main.id
  integration_type   = "AWS_PROXY"
  integration_uri    = var.lambda_arn              # FILL IN: e.g. module.lambda.lambda_arn
  integration_method = "POST"
}

# -----------------------------------------------
# Routes
# -----------------------------------------------
# Add one route block per API endpoint
# -----------------------------------------------
resource "aws_apigatewayv2_route" "post" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /jobs"                         # FILL IN: METHOD /path e.g. "GET /users"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

resource "aws_apigatewayv2_route" "get" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "GET /jobs/{id}"                     # FILL IN: adjust path and method
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id
}

# -----------------------------------------------
# Stage
# -----------------------------------------------
resource "aws_apigatewayv2_stage" "main" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "dev"                              # FILL IN: dev / staging / prod
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api.arn
  }

  default_route_settings {
    throttling_burst_limit = 100                   # FILL IN: max concurrent requests
    throttling_rate_limit  = 50                    # FILL IN: requests per second
  }
}

# -----------------------------------------------
# CloudWatch Log Group
# -----------------------------------------------
resource "aws_cloudwatch_log_group" "api" {
  name              = "/aws/apigateway/main-api"   # FILL IN: e.g. "/aws/apigateway/medbridge-api"
  retention_in_days = 30                           # FILL IN: days to keep logs
}

# -----------------------------------------------
# Lambda Permission
# -----------------------------------------------
# Allows API Gateway to invoke the Lambda function
# -----------------------------------------------
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name                  # FILL IN: e.g. module.lambda.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "api_endpoint" {
  description = "The HTTPS endpoint for the API"
  value       = aws_apigatewayv2_stage.main.invoke_url
}

output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_apigatewayv2_api.main.id
}
