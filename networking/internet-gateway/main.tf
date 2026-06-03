# -----------------------------------------------
# Internet Gateway
# -----------------------------------------------
# Attaches to the VPC and enables two-way
# communication between your VPC and the internet.
# One IGW per VPC — no exceptions.
# -----------------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id       # FILL IN: reference your VPC module output e.g. module.vpc.vpc_id

  tags = {
    Name        = "main-igw"                # FILL IN: e.g. "medbridge-igw"
    Environment = "dev"                     # FILL IN: dev / staging / prod
    Project     = "your-project-name"       # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}
