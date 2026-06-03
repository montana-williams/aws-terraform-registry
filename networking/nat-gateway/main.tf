# -----------------------------------------------
# NAT Gateway
# -----------------------------------------------
# Allows private subnet resources to reach the
# internet for outbound traffic only.
# Lives in a PUBLIC subnet — requires an Elastic IP.
# NOTE: Not free tier — destroy when not in use.
# -----------------------------------------------

# -----------------------------------------------
# Elastic IP
# -----------------------------------------------
# Static public IP attached to the NAT Gateway.
# Must be created before the NAT Gateway.
# -----------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "nat-eip"                 # FILL IN: e.g. "medbridge-nat-eip"
    Environment = "dev"                     # FILL IN: dev / staging / prod
    Project     = "your-project-name"       # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# NAT Gateway
# -----------------------------------------------
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id      # FILL IN: must be a PUBLIC subnet ID
                                            # e.g. module.vpc.public_subnet_ids[0]

  tags = {
    Name        = "main-nat-gateway"        # FILL IN: e.g. "medbridge-nat-gateway"
    Environment = "dev"                     # FILL IN: dev / staging / prod
    Project     = "your-project-name"       # FILL IN: e.g. "medbridge"
  }

  depends_on = [var.igw_id]                 # IGW must exist before NAT Gateway
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.main.id
}

output "nat_eip" {
  description = "The Elastic IP address of the NAT Gateway"
  value       = aws_eip.nat.public_ip
}
