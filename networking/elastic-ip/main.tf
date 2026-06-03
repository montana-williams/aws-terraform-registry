# -----------------------------------------------
# Elastic IP (EIP)
# -----------------------------------------------
# A static public IP address that persists
# regardless of resource stops, starts, or replacements.
# NOTE: AWS charges for unattached EIPs — always
# release when not in use.
# -----------------------------------------------

resource "aws_eip" "main" {
  domain = "vpc"

  # OPTIONAL: attach directly to an EC2 instance
  # instance = var.instance_id              # FILL IN: EC2 instance ID if attaching to EC2
                                            # Leave commented out if using with NAT Gateway
                                            # NAT Gateway handles its own EIP association

  tags = {
    Name        = "main-eip"               # FILL IN: e.g. "medbridge-bastion-eip"
    Environment = "dev"                    # FILL IN: dev / staging / prod
    Project     = "your-project-name"      # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "eip_public_ip" {
  description = "The static public IP address"
  value       = aws_eip.main.public_ip
}

output "eip_allocation_id" {
  description = "The allocation ID — needed to attach to a NAT Gateway"
  value       = aws_eip.main.id
}
