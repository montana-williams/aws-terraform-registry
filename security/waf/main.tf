# -----------------------------------------------
# WAF — Web Application Firewall
# -----------------------------------------------
# Protects public facing resources from malicious
# HTTP traffic at the application layer.
# Always start rules in COUNT mode during dev,
# switch to BLOCK mode after validating in production.
# -----------------------------------------------

# -----------------------------------------------
# Web ACL
# -----------------------------------------------
resource "aws_wafv2_web_acl" "main" {
  name  = "main-web-acl"                          # FILL IN: e.g. "medbridge-web-acl"
  scope = "REGIONAL"                              # FILL IN: REGIONAL or CLOUDFRONT
                                                  # REGIONAL — ALB, API Gateway, AppSync
                                                  # CLOUDFRONT — must be us-east-1 region

  default_action {
    allow {}                                      # Allow traffic that doesn't match any rule
                                                  # Change to block {} to deny by default
  }

  # -----------------------------------------------
  # AWS Managed Rules — Common Rule Set
  # -----------------------------------------------
  # Core protection against common web exploits
  # Start with override_action count{} during dev
  # Switch to none{} (use rule action) in production
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      count {}                                    # FILL IN: count{} for dev, none{} for production
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # AWS Managed Rules — SQL Injection
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesSQLiRuleSet"
    priority = 2

    override_action {
      count {}                                    # FILL IN: count{} for dev, none{} for production
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # AWS Managed Rules — Known Bad IPs
  # -----------------------------------------------
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      count {}                                    # FILL IN: count{} for dev, none{} for production
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IpReputationList"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # Custom Rule — Rate Limiting
  # -----------------------------------------------
  # Blocks IPs sending too many requests too fast
  # Basic DDoS and brute force protection
  # -----------------------------------------------
  rule {
    name     = "RateLimitRule"
    priority = 4

    action {
      block {}                                    # Block IPs that exceed the rate limit
    }

    statement {
      rate_based_statement {
        limit              = 1000                 # FILL IN: max requests per 5 minutes per IP
                                                  # 1000 is a reasonable starting point
                                                  # Lower for sensitive endpoints like /login
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRule"
      sampled_requests_enabled   = true
    }
  }

  # -----------------------------------------------
  # Custom Rule — IP Allow List (dev/testing)
  # -----------------------------------------------
  # Uncomment to allow your own IP through even
  # if managed rules would block it during testing
  # -----------------------------------------------
  # rule {
  #   name     = "AllowMyIP"
  #   priority = 0                                # Lowest number = evaluated first
  #
  #   action {
  #     allow {}
  #   }
  #
  #   statement {
  #     ip_set_reference_statement {
  #       arn = aws_wafv2_ip_set.allowed.arn
  #     }
  #   }
  #
  #   visibility_config {
  #     cloudwatch_metrics_enabled = true
  #     metric_name                = "AllowMyIP"
  #     sampled_requests_enabled   = true
  #   }
  # }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "main-web-acl"  # FILL IN: e.g. "medbridge-web-acl"
    sampled_requests_enabled   = true
  }

  tags = {
    Name        = "main-web-acl"                 # FILL IN: e.g. "medbridge-web-acl"
    Environment = "dev"                          # FILL IN: dev / staging / prod
    Project     = "your-project-name"            # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Associate WAF with ALB
# -----------------------------------------------
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn                     # FILL IN: e.g. module.alb.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}

# -----------------------------------------------
# IP Set (optional)
# -----------------------------------------------
# Use for custom IP allow or block lists
# -----------------------------------------------
# resource "aws_wafv2_ip_set" "allowed" {
#   name               = "allowed-ips"
#   scope              = "REGIONAL"
#   ip_address_version = "IPV4"
#   addresses          = ["YOUR_IP/32"]          # FILL IN: your IP address
# }

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "web_acl_arn" {
  description = "The ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "web_acl_id" {
  description = "The ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}
