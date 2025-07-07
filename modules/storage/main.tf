/*
 * AI Assistant Infrastructure - Storage Module
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Manages data storage infrastructure for the AI assistant
 *              Includes S3 Data Lake for documents and Aurora MySQL for transactional data
 *
 * Components:
 * - KMS encryption keys for data security
 * - S3 buckets with lifecycle policies for cost optimization
 * - Aurora MySQL Serverless v2 for automatic scaling
 * - Security groups with least-privilege access
 * - Secrets Manager for credential management
 *
 * Security Features:
 * - End-to-end encryption with customer-managed KMS keys
 * - S3 bucket policies blocking public access
 * - Database credentials stored in Secrets Manager
 * - Network isolation with VPC security groups
 */

# =============================================================================
# ENCRYPTION AND SECURITY
# =============================================================================

# Customer-managed KMS key for encrypting all storage resources
# Provides full control over encryption keys and access policies
resource "aws_kms_key" "storage" {
  description             = "KMS key for ${var.name_prefix} storage encryption (S3, Aurora, Secrets)"
  deletion_window_in_days = 7    # Minimum deletion window for recovery
  enable_key_rotation     = true # Automatic annual key rotation for security

  # Key policy allowing root account access and service usage
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow AWS Services"
        Effect = "Allow"
        Principal = {
          Service = [
            "s3.amazonaws.com",
            "rds.amazonaws.com",
            "secretsmanager.amazonaws.com"
          ]
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-storage-key"
    Purpose = "Storage encryption for AI assistant"
  })
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# User-friendly alias for the KMS key
# Makes it easier to reference the key in other resources and AWS console
resource "aws_kms_alias" "storage" {
  name          = "alias/${var.name_prefix}-storage" # Human-readable key identifier
  target_key_id = aws_kms_key.storage.key_id         # Reference to the actual key
}

# =============================================================================
# S3 DATA LAKE INFRASTRUCTURE
# =============================================================================

# S3 Data Lake Buckets for AI assistant document storage
# Organized by document lifecycle stage for efficient processing
resource "aws_s3_bucket" "data_lake" {
  for_each = toset([
    "raw-documents",       # Original uploaded documents (PDF, Word, Excel, images, videos)
    "processed-documents", # Documents after text extraction and preprocessing
    "embeddings",          # Vector embeddings for semantic search
    "user-uploads",        # Temporary storage for user-uploaded files
    "generated-documents", # AI-generated reports and responses
    "backup"               # Backup storage for critical data
  ])

  # Globally unique bucket name with random suffix
  bucket = "${var.name_prefix}-${each.key}-${var.random_suffix}"

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-${each.key}"
    Type     = "DataLake"
    Purpose  = "AI assistant document storage"
    Category = each.key
  })
}

# Server-side encryption configuration for all S3 buckets
# Uses customer-managed KMS key for enhanced security and control
resource "aws_s3_bucket_server_side_encryption_configuration" "data_lake" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id # Reference to each bucket created above

  rule {
    # Default encryption settings applied to all objects
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.storage.arn # Use our custom KMS key
      sse_algorithm     = "aws:kms"               # KMS encryption algorithm
    }
    bucket_key_enabled = true # Reduces KMS costs by using S3 bucket keys
  }
}

# S3 bucket versioning for data protection and recovery
# Maintains multiple versions of objects for accidental deletion protection
resource "aws_s3_bucket_versioning" "data_lake" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id # Apply to each bucket

  versioning_configuration {
    status = "Enabled" # Keep multiple versions of each object
  }
}

# S3 lifecycle policies for cost optimization through intelligent tiering
# Automatically moves data to cheaper storage classes based on access patterns
resource "aws_s3_bucket_lifecycle_configuration" "data_lake" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id

  # Rule 1: Transition objects to cheaper storage classes over time
  rule {
    id     = "cost_optimization_transitions" # Descriptive rule identifier
    status = "Enabled"                       # Rule is active

    # Apply to all objects
    filter {
      prefix = ""
    }

    # Move to Infrequent Access after 30 days (50% cost reduction)
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move to Glacier after 90 days (70% cost reduction)
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Move to Deep Archive after 1 year (80% cost reduction)
    transition {
      days          = 365
      storage_class = "DEEP_ARCHIVE"
    }
  }

  # Rule 2: Clean up incomplete multipart uploads to prevent storage charges
  rule {
    id     = "cleanup_incomplete_uploads" # Clean up failed uploads
    status = "Enabled"                    # Rule is active

    # Apply to all objects
    filter {
      prefix = ""
    }

    # Delete incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7 # Prevents accumulation of failed upload parts
    }
  }
}

# S3 public access block for enhanced security
# Prevents accidental public exposure of sensitive AI assistant data
resource "aws_s3_bucket_public_access_block" "data_lake" {
  for_each = aws_s3_bucket.data_lake

  bucket = each.value.id # Apply to each bucket

  # Block all forms of public access for maximum security
  block_public_acls       = true # Block public ACLs on bucket and objects
  block_public_policy     = true # Block public bucket policies
  ignore_public_acls      = true # Ignore existing public ACLs
  restrict_public_buckets = true # Restrict public bucket policies
}

# =============================================================================
# AURORA MYSQL DATABASE INFRASTRUCTURE
# =============================================================================

# Aurora database subnet group for multi-AZ deployment
# Places database instances in private subnets across multiple availability zones
resource "aws_db_subnet_group" "aurora" {
  name       = "${var.name_prefix}-aurora-subnet-group" # Unique identifier
  subnet_ids = var.private_subnets                      # Private subnets for security

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-aurora-subnet-group"
    Purpose = "Aurora database network isolation"
  })
}

# Security group for Aurora database clients (Lambda, ECS tasks)
# Allows application components to connect to the database
resource "aws_security_group" "aurora_client" {
  name_prefix = "${var.name_prefix}-aurora-client-" # Auto-generated unique name
  vpc_id      = var.vpc_id                          # VPC for network isolation
  description = "Security group for Aurora MySQL database clients"

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-aurora-client-sg"
    Purpose = "Aurora MySQL client access permissions"
  })
}

# Security group for Aurora database instances
# Implements least-privilege access allowing only application connections
resource "aws_security_group" "aurora" {
  name_prefix = "${var.name_prefix}-aurora-" # Auto-generated unique name
  vpc_id      = var.vpc_id                   # VPC for network isolation
  description = "Security group for Aurora MySQL database cluster"

  # Inbound rule: Allow MySQL connections only from application servers
  ingress {
    from_port       = 3306 # MySQL default port
    to_port         = 3306
    protocol        = "tcp"                                 # TCP protocol
    security_groups = [aws_security_group.aurora_client.id] # Only from client SG
    description     = "MySQL access from AI assistant applications"
  }

  # Outbound rule: Allow all outbound traffic (for updates, backups)
  egress {
    from_port   = 0 # All ports
    to_port     = 0
    protocol    = "-1"          # All protocols
    cidr_blocks = ["0.0.0.0/0"] # All destinations
    description = "All outbound traffic for database operations"
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-aurora-database-sg"
    Purpose = "Aurora MySQL database access control"
  })
}

# Security group rule for Aurora client outbound access
# Separate rule to avoid circular dependency
resource "aws_security_group_rule" "aurora_client_egress" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.aurora.id
  security_group_id        = aws_security_group.aurora_client.id
  description              = "MySQL access to Aurora database cluster"
}

# Note: Aurora managed master password is used instead of manual password management
# This provides better security with automatic rotation capabilities

# Aurora MySQL Serverless v2 cluster for AI assistant transactional data
# Automatically scales compute based on application demand
resource "aws_rds_cluster" "aurora" {
  # Basic cluster configuration
  cluster_identifier = "${var.name_prefix}-aurora-cluster" # Unique cluster name
  engine             = "aurora-mysql"                      # MySQL-compatible engine
  engine_version     = var.aurora_config.engine_version    # Specific MySQL version
  database_name      = "ai_assistant"                      # Default database name

  # Authentication and security
  master_username               = "admin"                 # Master username
  manage_master_user_password   = true                    # AWS-managed password
  master_user_secret_kms_key_id = aws_kms_key.storage.arn # Encrypt credentials

  # Network and security configuration
  vpc_security_group_ids = [aws_security_group.aurora.id]  # Database security group
  db_subnet_group_name   = aws_db_subnet_group.aurora.name # Multi-AZ subnet group

  # Backup and maintenance configuration
  backup_retention_period      = var.aurora_config.backup_retention   # Days to retain backups
  preferred_backup_window      = var.aurora_config.backup_window      # UTC backup window
  preferred_maintenance_window = var.aurora_config.maintenance_window # UTC maintenance window

  # Encryption configuration
  storage_encrypted = true                    # Encrypt data at rest
  kms_key_id        = aws_kms_key.storage.arn # Use custom KMS key

  # Data protection
  deletion_protection = var.aurora_config.deletion_protection # Prevent accidental deletion

  # Serverless v2 auto-scaling configuration
  serverlessv2_scaling_configuration {
    max_capacity = var.aurora_config.max_capacity # Maximum Aurora Capacity Units
    min_capacity = var.aurora_config.min_capacity # Minimum Aurora Capacity Units
  }

  # CloudWatch logs for monitoring and debugging
  enabled_cloudwatch_logs_exports = [
    "audit",    # Database audit logs
    "error",    # Error logs
    "general",  # General query logs
    "slowquery" # Slow query logs for optimization
  ]

  # Final snapshot configuration
  skip_final_snapshot       = false # Create final snapshot when deleting
  final_snapshot_identifier = "${var.name_prefix}-aurora-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-aurora-cluster"
    Engine   = "Aurora MySQL Serverless v2"
    Purpose  = "AI assistant transactional database"
    Database = "ai_assistant"
  })

  # Lifecycle management
  lifecycle {
    ignore_changes = [final_snapshot_identifier] # Prevent changes to snapshot name
  }
}

# Aurora cluster instances for high availability
# Deploys instances across multiple availability zones
resource "aws_rds_cluster_instance" "aurora" {
  count = 2 # Two instances for high availability

  # Instance identification
  identifier         = "${var.name_prefix}-aurora-${count.index}" # Unique instance name
  cluster_identifier = aws_rds_cluster.aurora.id                  # Parent cluster reference

  # Instance configuration
  instance_class = var.aurora_config.instance_class      # Serverless v2 instance class
  engine         = aws_rds_cluster.aurora.engine         # Inherit from cluster
  engine_version = aws_rds_cluster.aurora.engine_version # Inherit from cluster

  # Monitoring and performance
  performance_insights_enabled = true # Enable Performance Insights for query analysis
  monitoring_interval          = 60   # Enhanced monitoring every 60 seconds

  tags = merge(var.tags, {
    Name     = "${var.name_prefix}-aurora-instance-${count.index}"
    Purpose  = "Aurora MySQL instance for AI assistant"
    Instance = "${count.index + 1}" # Human-readable instance number
  })
}