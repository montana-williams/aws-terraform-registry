# -----------------------------------------------
# RDS — Relational Database Service
# -----------------------------------------------
# Managed relational database.
# Always deploy in private subnets.
# Never open to 0.0.0.0/0 — use security group
# chaining to allow only your app layer.
# -----------------------------------------------

# -----------------------------------------------
# DB Subnet Group
# -----------------------------------------------
# Tells RDS which subnets it can use.
# Must span at least 2 AZs for Multi-AZ support.
# -----------------------------------------------
resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"               # FILL IN: e.g. "medbridge-db-subnet-group"
  subnet_ids = var.private_subnet_ids               # FILL IN: e.g. module.vpc.private_subnet_ids
                                                    # Must be private subnets across 2+ AZs

  tags = {
    Name        = "main-db-subnet-group"
    Environment = "dev"                             # FILL IN: dev / staging / prod
    Project     = "your-project-name"               # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# RDS Instance
# -----------------------------------------------
resource "aws_db_instance" "main" {
  identifier        = "main-db"                     # FILL IN: e.g. "medbridge-db"
  engine            = "mysql"                       # FILL IN: mysql / postgres / mariadb /
                                                    # aurora-mysql / aurora-postgresql
  engine_version    = "8.0"                         # FILL IN: check AWS docs for latest stable version
  instance_class    = "db.t3.micro"                 # FILL IN: match to your workload
                                                    # db.t3.micro — dev/free tier eligible
                                                    # db.t3.medium — light production
                                                    # db.r5.large — memory heavy production

  allocated_storage     = 20                        # FILL IN: initial storage in GB
  max_allocated_storage = 100                       # FILL IN: max storage for auto scaling
                                                    # RDS will expand automatically up to this limit

  db_name  = "appdb"                                # FILL IN: your database name e.g. "medbridge"
  username = var.db_username                        # FILL IN: master username — store in Secrets Manager
  password = var.db_password                        # FILL IN: master password — store in Secrets Manager
                                                    # Never hardcode credentials in Terraform

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]          # FILL IN: e.g. module.security_groups.rds_sg_id
                                                    # Only allow traffic from app security group

  # -----------------------------------------------
  # Availability
  # -----------------------------------------------
  multi_az = true                                   # Always true in production
                                                    # Creates standby in separate AZ for automatic failover
                                                    # Set false for dev to save cost

  # -----------------------------------------------
  # Backups
  # -----------------------------------------------
  backup_retention_period = 7                       # FILL IN: days to retain backups (1-35)
                                                    # 7 days is a reasonable default
  backup_window           = "03:00-04:00"           # FILL IN: preferred backup window (UTC)
  maintenance_window      = "Mon:04:00-Mon:05:00"   # FILL IN: preferred maintenance window

  # -----------------------------------------------
  # Security
  # -----------------------------------------------
  storage_encrypted = true                          # Always true — required for HIPAA and PCI-DSS
                                                    # Must be set at creation, cannot be added after
  publicly_accessible = false                       # Never true — RDS stays in private subnets

  # -----------------------------------------------
  # Deletion protection
  # -----------------------------------------------
  deletion_protection      = false                  # FILL IN: set true in production
  skip_final_snapshot      = true                   # FILL IN: set false in production
                                                    # Takes a final snapshot before deletion
  final_snapshot_identifier = "main-db-final"      # FILL IN: name for final snapshot

  tags = {
    Name        = "main-db"                        # FILL IN: e.g. "medbridge-db"
    Environment = "dev"                            # FILL IN: dev / staging / prod
    Project     = "your-project-name"              # FILL IN: e.g. "medbridge"
  }
}

# -----------------------------------------------
# Read Replica (optional)
# -----------------------------------------------
# Uncomment to add a read replica for heavy
# read workloads. Point read queries here,
# write queries to the primary.
# -----------------------------------------------
# resource "aws_db_instance" "replica" {
#   identifier          = "main-db-replica"
#   replicate_source_db = aws_db_instance.main.identifier
#   instance_class      = "db.t3.micro"             # FILL IN: can be smaller than primary
#   publicly_accessible = false
#   storage_encrypted   = true
#   skip_final_snapshot = true
#
#   tags = {
#     Name        = "main-db-replica"
#     Environment = "dev"
#     Project     = "your-project-name"
#   }
# }

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "db_endpoint" {
  description = "The connection endpoint for the database"
  value       = aws_db_instance.main.endpoint
}

output "db_name" {
  description = "The database name"
  value       = aws_db_instance.main.db_name
}
