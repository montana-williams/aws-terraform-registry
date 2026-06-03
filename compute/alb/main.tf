# -----------------------------------------------
# ALB — Application Load Balancer
# -----------------------------------------------
# Single entry point for all user traffic.
# Lives in public subnets, forwards to instances
# in private subnets via target group.
# -----------------------------------------------

# -----------------------------------------------
# Application Load Balancer
# -----------------------------------------------
resource "aws_lb" "main" {
  name               = "app-alb"                    # FILL IN: e.g. "medbridge-alb"
  internal           = false                         # false = internet facing, true = internal only
  load_balancer_type = "application"                 # application = ALB (layer 7)
  security_groups    = [var.alb_sg_id]               # FILL IN: e.g. module.security_groups.alb_sg_id
  subnets            = var.public_subnet_ids         # FILL IN: ALB always goes in PUBLIC subnets
                                                     # e.g. module.vpc.public_subnet_ids

  enable_deletion_protection = false                 # FILL IN: set true in production to prevent
                                                     # accidental deletion

  tags = {
    Name        = "app-alb"                         # FILL IN: e.g. "medbridge-alb"
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Target Group
# -----------------------------------------------
# Where the ALB sends traffic.
# Auto Scaling registers instances into this group.
# -----------------------------------------------
resource "aws_lb_target_group" "main" {
  name     = "app-tg"                               # FILL IN: e.g. "medbridge-tg"
  port     = 80                                     # FILL IN: port your app listens on
  protocol = "HTTP"                                 # HTTP between ALB and instances is fine
                                                    # HTTPS is handled at the ALB listener
  vpc_id   = var.vpc_id                             # FILL IN: e.g. module.vpc.vpc_id

  health_check {
    enabled             = true
    path                = "/health"                 # FILL IN: your app health check endpoint
                                                    # must return 200 OK when healthy
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2                         # healthy after 2 consecutive successes
    unhealthy_threshold = 3                         # unhealthy after 3 consecutive failures
    timeout             = 5                         # seconds to wait for response
    interval            = 30                        # seconds between health checks
    matcher             = "200"                     # expected response code
  }

  tags = {
    Name        = "app-tg"                         # FILL IN: e.g. "medbridge-tg"
    Environment = "dev"                            # FILL IN: dev / staging / prod
    Project     = "your-project-name"              # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# HTTPS Listener
# -----------------------------------------------
# Primary listener — all production traffic
# SSL certificate managed by ACM
# -----------------------------------------------
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"  # Current recommended TLS policy
  certificate_arn   = var.acm_certificate_arn                 # FILL IN: your ACM certificate ARN
                                                              # Create in ACM console before deploying

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# -----------------------------------------------
# HTTP Listener
# -----------------------------------------------
# Redirects all HTTP traffic to HTTPS
# Never serve real traffic over HTTP
# -----------------------------------------------
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"                     # Permanent redirect
    }
  }
}

# -----------------------------------------------
# Optional: Path Based Routing Rule
# -----------------------------------------------
# Uncomment and configure to route different paths
# to different target groups
# -----------------------------------------------
# resource "aws_lb_listener_rule" "api" {
#   listener_arn = aws_lb_listener.https.arn
#   priority     = 100
#
#   action {
#     type             = "forward"
#     target_group_arn = var.api_target_group_arn   # FILL IN: separate target group for API
#   }
#
#   condition {
#     path_pattern {
#       values = ["/api/*"]                         # FILL IN: path pattern to match
#     }
#   }
# }

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "alb_dns_name" {
  description = "The DNS name of the ALB — use this as your app endpoint"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "The ARN of the target group — pass to Auto Scaling module"
  value       = aws_lb_target_group.main.arn
}
