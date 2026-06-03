# -----------------------------------------------
# VPC — Virtual Private Cloud
# -----------------------------------------------
# This example creates a production-ready VPC with:
# - Public and private subnets across 2 AZs
# - Internet Gateway for public subnet access
# - NAT Gateway for private subnet outbound access
# - Route tables wired to the correct gateways
# -----------------------------------------------

# -----------------------------------------------
# VPC
# -----------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"   # FILL IN: your IP range — /16 is standard for most projects
  enable_dns_support   = true             # Required for RDS and internal DNS resolution
  enable_dns_hostnames = true             # Required if you want public DNS hostnames on EC2

  tags = {
    Name        = "your-project-vpc"      # FILL IN: e.g. "medbridge-vpc"
    Environment = "dev"                   # FILL IN: dev / staging / prod
    Project     = "your-project-name"     # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Public Subnets (one per AZ)
# -----------------------------------------------
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"        # FILL IN: carve from your VPC range — /24 gives 251 usable hosts
  availability_zone       = "us-east-1a"          # FILL IN: your region + AZ e.g. us-east-1a
  map_public_ip_on_launch = true                  # Assigns public IPs to resources launched here

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"         # FILL IN: different range from public_1
  availability_zone       = "us-east-1b"           # FILL IN: different AZ from public_1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2"
  }
}

# -----------------------------------------------
# Private Subnets (one per AZ)
# -----------------------------------------------
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"               # FILL IN: non-overlapping range
  availability_zone = "us-east-1a"                 # FILL IN: match public_1 AZ

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"               # FILL IN: non-overlapping range
  availability_zone = "us-east-1b"                 # FILL IN: match public_2 AZ

  tags = {
    Name = "private-subnet-2"
  }
}

# -----------------------------------------------
# Internet Gateway
# -----------------------------------------------
# The two-way door — attaches to your VPC and
# allows public subnets to reach the internet
# -----------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# -----------------------------------------------
# NAT Gateway
# -----------------------------------------------
# The one-way glass — lets private subnets reach
# out to the internet without being reachable from it.
# Requires an Elastic IP and lives in a PUBLIC subnet.
# NOTE: NAT Gateway is not free tier — destroy when not in use.
# -----------------------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id   # NAT Gateway always goes in a PUBLIC subnet

  tags = {
    Name = "main-nat-gateway"
  }

  depends_on = [aws_internet_gateway.main]  # IGW must exist before NAT Gateway
}

# -----------------------------------------------
# Route Tables
# -----------------------------------------------
# Public route table — sends internet traffic to IGW
# -----------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"                        # All internet traffic
    gateway_id = aws_internet_gateway.main.id        # Goes through the IGW
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------
# Private route table — sends internet traffic to NAT
# -----------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"                    # All internet traffic
    nat_gateway_id = aws_nat_gateway.main.id         # Goes through NAT Gateway (outbound only)
  }

  tags = {
    Name = "private-rt"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = [aws_subnet.public_1.id, aws_subnet.public_2.id]
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}
