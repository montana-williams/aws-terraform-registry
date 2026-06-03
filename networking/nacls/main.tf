# -----------------------------------------------
# Network ACL (NACL)
# -----------------------------------------------
# Stateless subnet-level firewall.
# Rules are evaluated in order — first match wins.
# Must explicitly allow both inbound AND outbound.
# Remember ephemeral ports 1024-65535 for responses.
# -----------------------------------------------

# -----------------------------------------------
# Public Subnet NACL
# -----------------------------------------------
resource "aws_network_acl" "public" {
  vpc_id     = var.vpc_id                         # FILL IN: e.g. module.vpc.vpc_id
  subnet_ids = var.public_subnet_ids              # FILL IN: e.g. module.vpc.public_subnet_ids

  # -----------------------------------------------
  # Inbound rules
  # -----------------------------------------------

  # Allow HTTPS inbound from internet
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow HTTP inbound from internet
  ingress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow ephemeral ports inbound — responses from internet
  # back to resources that initiated outbound connections
  ingress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # -----------------------------------------------
  # Outbound rules
  # -----------------------------------------------

  # Allow HTTPS outbound to internet
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # Allow HTTP outbound to internet
  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  # Allow ephemeral ports outbound — responses back to clients
  # CRITICAL: without this responses to inbound requests are dropped
  egress {
    rule_no    = 120
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name        = "public-nacl"            # FILL IN: e.g. "medbridge-public-nacl"
    Environment = "dev"                    # FILL IN: dev / staging / prod
    Project     = "your-project-name"      # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Private Subnet NACL
# -----------------------------------------------
resource "aws_network_acl" "private" {
  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids             # FILL IN: e.g. module.vpc.private_subnet_ids

  # -----------------------------------------------
  # Inbound rules
  # -----------------------------------------------

  # Allow traffic from VPC only — no direct internet access
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.0.0/16"                   # FILL IN: your VPC CIDR range
    from_port  = 0
    to_port    = 65535
  }

  # -----------------------------------------------
  # Outbound rules
  # -----------------------------------------------

  # Allow responses back within VPC
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.0.0/16"                   # FILL IN: your VPC CIDR range
    from_port  = 0
    to_port    = 65535
  }

  # Allow outbound to internet via NAT Gateway
  # for updates, downloads, external API calls
  egress {
    rule_no    = 110
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name        = "private-nacl"           # FILL IN: e.g. "medbridge-private-nacl"
    Environment = "dev"                    # FILL IN: dev / staging / prod
    Project     = "your-project-name"      # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "public_nacl_id" {
  description = "The ID of the public NACL"
  value       = aws_network_acl.public.id
}

output "private_nacl_id" {
  description = "The ID of the private NACL"
  value       = aws_network_acl.private.id
}
