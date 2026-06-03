# -----------------------------------------------
# Route Tables
# -----------------------------------------------
# Two route tables — one for public subnets routing
# to the IGW, one for private subnets routing to
# the NAT Gateway.
# -----------------------------------------------

# -----------------------------------------------
# Public Route Table
# -----------------------------------------------
# Routes all internet traffic to the IGW
# Associate with all public subnets
# -----------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id                       # FILL IN: e.g. module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"               # All internet-bound traffic
    gateway_id = var.igw_id                 # FILL IN: e.g. module.igw.igw_id
  }

  tags = {
    Name        = "public-rt"              # FILL IN: e.g. "medbridge-public-rt"
    Environment = "dev"                    # FILL IN: dev / staging / prod
    Project     = "your-project-name"      # FILL IN: e.g. "medbridge"
  }
}

# Associate public route table with public subnets
# Add one association block per public subnet
resource "aws_route_table_association" "public_1" {
  subnet_id      = var.public_subnet_1_id   # FILL IN: e.g. module.vpc.public_subnet_ids[0]
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = var.public_subnet_2_id   # FILL IN: e.g. module.vpc.public_subnet_ids[1]
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------
# Private Route Table
# -----------------------------------------------
# Routes all internet traffic to the NAT Gateway
# Outbound only — inbound from internet is blocked
# Associate with all private subnets
# -----------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"           # All internet-bound traffic
    nat_gateway_id = var.nat_gateway_id     # FILL IN: e.g. module.nat.nat_gateway_id
  }

  tags = {
    Name        = "private-rt"             # FILL IN: e.g. "medbridge-private-rt"
    Environment = "dev"                    # FILL IN: dev / staging / prod
    Project     = "your-project-name"      # FILL IN: e.g. "medbridge"
  }
}

# Associate private route table with private subnets
# Add one association block per private subnet
resource "aws_route_table_association" "private_1" {
  subnet_id      = var.private_subnet_1_id  # FILL IN: e.g. module.vpc.private_subnet_ids[0]
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = var.private_subnet_2_id  # FILL IN: e.g. module.vpc.private_subnet_ids[1]
  route_table_id = aws_route_table.private.id
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = aws_route_table.private.id
}
