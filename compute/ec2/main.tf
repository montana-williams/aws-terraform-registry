# -----------------------------------------------
# EC2 — Elastic Compute Cloud
# -----------------------------------------------
# A virtual server inside your VPC.
# Always launch into a private subnet unless the
# instance absolutely needs direct internet exposure.
# Use an ALB in front for public facing workloads.
# -----------------------------------------------

# -----------------------------------------------
# EC2 Instance
# -----------------------------------------------
resource "aws_instance" "main" {
  ami                    = "ami-0c02fb55956c7d316"   # FILL IN: find current AMI for your region
                                                      # Amazon Linux 2: search AMI catalog in console
                                                      # Ubuntu 22.04: ami-0c7217cdde317cfec (us-east-1)
  instance_type          = "t3.micro"                 # FILL IN: match to your workload
                                                      # t3.micro — dev/low traffic (free tier eligible)
                                                      # t3.small/medium — light production
                                                      # c5.large — compute heavy
                                                      # r5.large — memory heavy (databases)

  subnet_id              = var.private_subnet_id      # FILL IN: e.g. module.vpc.private_subnet_ids[0]
                                                      # Use public subnet only for bastion hosts
  vpc_security_group_ids = [var.app_sg_id]            # FILL IN: e.g. module.security_groups.app_sg_id
  key_name               = var.key_pair_name          # FILL IN: your EC2 key pair name for SSH access
                                                      # Create in EC2 console → Key Pairs before deploying

  # -----------------------------------------------
  # Root EBS Volume
  # -----------------------------------------------
  root_block_device {
    volume_size           = 20                        # FILL IN: size in GB — 20 is a reasonable default
    volume_type           = "gp3"                     # gp3 is current gen general purpose SSD
    encrypted             = true                      # Always encrypt — required for HIPAA and PCI-DSS
    delete_on_termination = true                      # Set to false if you want EBS to survive termination
  }

  # -----------------------------------------------
  # User Data
  # -----------------------------------------------
  # Optional: commands to run on first boot
  # Use to install software, pull your app, configure the server
  # -----------------------------------------------
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    # FILL IN: add your bootstrap commands here
    # e.g. install nginx, pull from S3, start your app
  EOF

  tags = {
    Name        = "app-server"             # FILL IN: e.g. "medbridge-app-server"
    Environment = "dev"                    # FILL IN: dev / staging / prod
    Project     = "your-project-name"      # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# EBS Snapshot (backup)
# -----------------------------------------------
# In production automate this with AWS Backup
# or Data Lifecycle Manager instead of managing manually
# -----------------------------------------------
# resource "aws_ebs_snapshot" "main" {
#   volume_id   = aws_instance.main.root_block_device[0].volume_id
#   description = "Snapshot of app server root volume"
#
#   tags = {
#     Name = "app-server-snapshot"
#   }
# }

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.main.private_ip
}
