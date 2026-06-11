# -----------------------------------------------
# ElastiCache — Redis Replication Group
# -----------------------------------------------
# Managed in-memory data store for caching
# frequently accessed data and session storage.
# Reduces database load and improves response times.
#
# This example creates:
# - Subnet group across private subnets
# - Parameter group with LRU eviction policy
# - Redis replication group with Multi-AZ failover
# -----------------------------------------------

# -----------------------------------------------
# Subnet Group
# -----------------------------------------------
# Tells ElastiCache which subnets to deploy into.
# Always use private subnets — Redis should never
# be directly accessible from the internet.
# -----------------------------------------------
resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.project_name}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-cache-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------
# Parameter Group
# -----------------------------------------------
# Configuration settings for your Redis cluster.
# allkeys-lru = evict least recently used keys
# when memory is full — best for general caching.
# -----------------------------------------------
resource "aws_elasticache_parameter_group" "main" {
  name   = "${var.project_name}-cache-params"
  family = "redis7"                                # FILL IN: match your engine version

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"                          # Evict least recently used keys first
  }

  parameter {
    name  = "latency-tracking"
    value = "yes"                                  # Enable latency tracking for CloudWatch
  }
}

# -----------------------------------------------
# Replication Group
# -----------------------------------------------
# The actual Redis cluster. Primary node handles
# writes, replica handles reads. Automatic failover
# promotes replica if primary fails.
# -----------------------------------------------
resource "aws_elasticache_replication_group" "main" {
  replication_group_id       = "${var.project_name}-redis"
  description                = "${var.project_name} Redis replication group"

  engine_version             = "7.0"              # FILL IN: Redis version
  node_type                  = var.node_type      # FILL IN: cache.t3.micro for dev,
                                                  # cache.r6g.large for production
  num_cache_clusters         = 2                  # Primary + 1 replica minimum for HA

  automatic_failover_enabled = true               # Required for Multi-AZ
  multi_az_enabled           = true               # Deploys nodes across AZs

  subnet_group_name          = aws_elasticache_subnet_group.main.name
  security_group_ids         = [var.elasticache_sg_id]
  parameter_group_name       = aws_elasticache_parameter_group.main.name

  preferred_cache_cluster_azs = ["us-east-1a", "us-east-1b"]  # FILL IN: your AZs

  at_rest_encryption_enabled = true               # Encrypt data at rest — required for PCI-DSS
  transit_encryption_enabled = true               # Encrypt data in transit — required for PCI-DSS

  tags = {
    Name        = "${var.project_name}-redis"
    Environment = var.environment
    Project     = var.project_name
  }
}

# -----------------------------------------------
# Outputs
# -----------------------------------------------
output "redis_endpoint" {
  description = "Primary endpoint — use this in your app config to connect to Redis"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port — default 6379"
  value       = aws_elasticache_replication_group.main.port
}

output "replication_group_id" {
  description = "Replication group ID — pass to monitoring module for CloudWatch alarms"
  value       = aws_elasticache_replication_group.main.id
}

# -----------------------------------------------
# Variables
# -----------------------------------------------
# variable "project_name" {
#   description = "Project name for naming and tagging"
#   type        = string
# }
#
# variable "environment" {
#   description = "Deployment environment — dev, staging, production"
#   type        = string
#   default     = "dev"
# }
#
# variable "private_subnet_ids" {
#   description = "Private subnet IDs — from VPC module"
#   type        = list(string)
# }
#
# variable "elasticache_sg_id" {
#   description = "Security group ID for ElastiCache — from security module"
#   type        = string
# }
#
# variable "node_type" {
#   description = "ElastiCache node type. cache.t3.micro for dev, cache.r6g.large for prod"
#   type        = string
#   default     = "cache.t3.micro"
# }
