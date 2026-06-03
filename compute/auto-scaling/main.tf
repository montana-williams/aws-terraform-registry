# -----------------------------------------------
# Auto Scaling
# -----------------------------------------------
# Automatically adjusts EC2 instance count based
# on demand. Works with a load balancer and target
# group to distribute traffic to healthy instances.
# -----------------------------------------------

# -----------------------------------------------
# Launch Template
# -----------------------------------------------
# Blueprint for every instance Auto Scaling spawns.
# Change the template version to roll out updates.
# -----------------------------------------------
resource "aws_launch_template" "main" {
  name_prefix   = "app-lt-"                          # FILL IN: e.g. "medbridge-lt-"
  image_id      = var.ami_id                         # FILL IN: e.g. module.ec2.ami_id or hardcoded AMI
  instance_type = "t3.micro"                         # FILL IN: match to your workload
                                                     # t3.micro — dev/low traffic
                                                     # t3.medium — light production
                                                     # c5.large — compute heavy

  vpc_security_group_ids = [var.app_sg_id]           # FILL IN: e.g. module.security_groups.app_sg_id
  key_name               = var.key_pair_name         # FILL IN: your EC2 key pair name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20                     # FILL IN: root volume size in GB
      volume_type           = "gp3"
      encrypted             = true                   # Always encrypt
      delete_on_termination = true
    }
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    # FILL IN: bootstrap commands to configure your instance on first boot
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "app-server"                     # FILL IN: e.g. "medbridge-app-server"
      Environment = "dev"                            # FILL IN: dev / staging / prod
      Project     = "your-project-name"              # FILL IN: e.g. "medbridge"
    }
  }
}

# -----------------------------------------------
# Auto Scaling Group
# -----------------------------------------------
resource "aws_autoscaling_group" "main" {
  name                = "app-asg"                    # FILL IN: e.g. "medbridge-asg"
  min_size            = 2                            # FILL IN: always at least 2 for HA
  desired_capacity    = 2                            # FILL IN: normal steady state
  max_size            = 6                            # FILL IN: cap to control costs

  vpc_zone_identifier = var.private_subnet_ids       # FILL IN: e.g. module.vpc.private_subnet_ids
                                                     # Spread across multiple AZs for HA
  target_group_arns   = [var.target_group_arn]       # FILL IN: e.g. module.alb.target_group_arn

  health_check_type         = "ELB"                  # Use ELB health checks not just EC2 status
  health_check_grace_period = 300                    # FILL IN: seconds to wait before health checks start
                                                     # Give instances time to boot — 300 is a safe default

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"                              # Always use latest template version
  }

  tag {
    key                 = "Name"
    value               = "app-asg-instance"         # FILL IN: e.g. "medbridge-asg-instance"
    propagate_at_launch = true
  }
}

# -----------------------------------------------
# Scaling Policy — Target Tracking
# -----------------------------------------------
# Keeps average CPU utilization at 60%
# Auto Scaling adds instances when above, removes when below
# -----------------------------------------------
resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0                              # FILL IN: target CPU % — 60 is a reasonable default
                                                     # Lower = scale sooner, Higher = scale later
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "asg_name" {
  description = "The name of the Auto Scaling group"
  value       = aws_autoscaling_group.main.name
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.main.id
}
