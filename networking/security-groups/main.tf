# -----------------------------------------------
# Security Groups
# -----------------------------------------------
# This example shows the most common security group
# chain for a 3-tier architecture:
# ALB → EC2/Lambda → RDS
# Each layer only accepts traffic from the layer
# directly in front of it.
# -----------------------------------------------

# -----------------------------------------------
# ALB Security Group
# -----------------------------------------------
# Faces the public internet — only allows
# HTTP and HTTPS from anywhere
# -----------------------------------------------
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow inbound HTTP and HTTPS from the internet"
  vpc_id      = var.vpc_id                  # FILL IN: reference your VPC module output

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]             # Public facing — open to all
  }

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]             # Consider redirecting HTTP → HTTPS at ALB level
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"                      # -1 means all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

# -----------------------------------------------
# Application Security Group (EC2 or Lambda)
# -----------------------------------------------
# Only accepts traffic from the ALB security group
# Never open this to 0.0.0.0/0
# -----------------------------------------------
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Allow inbound only from ALB security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow traffic from ALB only"
    from_port       = 8080                          # FILL IN: your app port e.g. 8080, 3000, 5000
    to_port         = 8080                          # FILL IN: match from_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]   # Only ALB can reach this — not the open internet
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

# -----------------------------------------------
# RDS Security Group
# -----------------------------------------------
# Only accepts traffic from the app security group
# Database should never be reachable from the internet
# -----------------------------------------------
resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow inbound only from app security group"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow DB traffic from app layer only"
    from_port       = 5432                          # FILL IN: 5432 PostgreSQL / 3306 MySQL / 1433 MSSQL
    to_port         = 5432                          # FILL IN: match from_port
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]   # Only app layer can reach DB — security group chaining
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "alb_sg_id" {
  description = "Security group ID for the ALB"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "Security group ID for the application layer"
  value       = aws_security_group.app.id
}

output "rds_sg_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds.id
}
