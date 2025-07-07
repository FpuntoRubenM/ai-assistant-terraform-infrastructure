/*
 * AI Assistant Infrastructure - AI Services Module
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: AI/ML services for the AI assistant infrastructure
 *              Provides vector search, language models, and optional custom ML endpoints
 *
 * Components:
 * - OpenSearch cluster for vector embeddings and semantic search
 * - Bedrock integration for language models and embeddings
 * - Optional SageMaker endpoints for custom models
 * - CloudWatch logging for monitoring and debugging
 *
 * Security Features:
 * - VPC isolation for OpenSearch cluster
 * - Fine-grained authentication and authorization
 * - Encryption at rest and in transit
 * - Security groups with least-privilege access
 */

# =============================================================================
# OPENSEARCH VECTOR STORE
# =============================================================================

# OpenSearch cluster for vector embeddings and semantic search
# Stores document embeddings and provides fast similarity search capabilities
resource "aws_opensearch_domain" "vector_store" {
  domain_name    = "${var.name_prefix}-vector-store" # Unique domain identifier
  engine_version = "OpenSearch_2.3"                  # Latest stable OpenSearch version

  # Cluster configuration for high availability and performance
  cluster_config {
    instance_type  = var.opensearch_config.instance_type  # Node instance type
    instance_count = var.opensearch_config.instance_count # Number of data nodes

    # Dedicated master nodes for cluster management (recommended for production)
    dedicated_master_enabled = var.opensearch_config.instance_count > 2
    dedicated_master_type    = var.opensearch_config.instance_count > 2 ? "t3.small.search" : null
    dedicated_master_count   = var.opensearch_config.instance_count > 2 ? 3 : null

    # Multi-AZ deployment for high availability
    zone_awareness_enabled = var.opensearch_config.instance_count > 1

    # Configure AZ distribution when zone awareness is enabled
    dynamic "zone_awareness_config" {
      for_each = var.opensearch_config.instance_count > 1 ? [1] : []
      content {
        availability_zone_count = min(2, length(var.private_subnets)) # Use available AZs
      }
    }
  }

  # EBS storage configuration for persistent data
  ebs_options {
    ebs_enabled = true                              # Enable EBS volumes
    volume_type = var.opensearch_config.volume_type # SSD volume type (gp3 recommended)
    volume_size = var.opensearch_config.volume_size # Storage size per node
  }

  # VPC configuration for network isolation
  vpc_options {
    subnet_ids         = slice(var.private_subnets, 0, min(2, length(var.private_subnets)))
    security_group_ids = [aws_security_group.opensearch.id] # Security group for access control
  }

  # Encryption at rest for data security
  encrypt_at_rest {
    enabled = true # Encrypt stored data
  }

  # Node-to-node encryption for data in transit
  node_to_node_encryption {
    enabled = true # Encrypt inter-node communication
  }

  # HTTPS enforcement and TLS configuration
  domain_endpoint_options {
    enforce_https       = true                         # Force HTTPS connections
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07" # Modern TLS policy
  }

  # Fine-grained access control for enhanced security
  advanced_security_options {
    enabled                        = true  # Enable fine-grained access control
    anonymous_auth_enabled         = false # Disable anonymous access
    internal_user_database_enabled = true  # Use internal user database

    # Master user configuration
    master_user_options {
      master_user_name     = "admin"                                  # Master username
      master_user_password = random_password.opensearch_master.result # Generated password
    }
  }

  # CloudWatch log publishing for monitoring
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "INDEX_SLOW_LOGS" # Index performance logs
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "SEARCH_SLOW_LOGS" # Search performance logs
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "ES_APPLICATION_LOGS" # General application logs
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-opensearch"
    Purpose = "Vector embeddings and semantic search"
    Engine  = "OpenSearch 2.3"
  })
}

# Generate secure random password for OpenSearch master user
# Password meets AWS complexity requirements
resource "random_password" "opensearch_master" {
  length  = 16   # 16 character password
  special = true # Include special characters

  # Ensure password meets OpenSearch requirements
  min_lower   = 2
  min_upper   = 2
  min_numeric = 2
  min_special = 2
}

# Security group for OpenSearch clients (Lambda, ECS tasks)
# Allows applications to connect to the OpenSearch cluster
resource "aws_security_group" "opensearch_client" {
  name_prefix = "${var.name_prefix}-opensearch-client-" # Auto-generated unique name
  vpc_id      = var.vpc_id                              # VPC for network isolation
  description = "Security group for OpenSearch cluster clients"

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-opensearch-client-sg"
    Purpose = "OpenSearch client access permissions"
  })
}

# Security group for OpenSearch cluster
# Allows HTTPS access only from authorized client applications
resource "aws_security_group" "opensearch" {
  name_prefix = "${var.name_prefix}-opensearch-" # Auto-generated unique name
  vpc_id      = var.vpc_id                       # VPC for network isolation
  description = "Security group for OpenSearch vector store cluster"

  # Inbound rule: Allow HTTPS connections from client security group
  ingress {
    from_port       = 443 # HTTPS port
    to_port         = 443
    protocol        = "tcp"                                     # TCP protocol
    security_groups = [aws_security_group.opensearch_client.id] # Only from clients
    description     = "HTTPS access from AI assistant applications"
  }

  # No explicit egress rules (default allows all outbound)
  # OpenSearch needs outbound access for cluster operations

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-opensearch-cluster-sg"
    Purpose = "OpenSearch cluster network security"
  })
}

# Security group rule for OpenSearch client outbound access
# Separate rule to avoid circular dependency
resource "aws_security_group_rule" "opensearch_client_egress" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.opensearch.id
  security_group_id        = aws_security_group.opensearch_client.id
  description              = "HTTPS access to OpenSearch vector store"
}

# =============================================================================
# CLOUDWATCH LOGGING
# =============================================================================

# CloudWatch log group for OpenSearch cluster logs
# Centralized logging for monitoring and troubleshooting
resource "aws_cloudwatch_log_group" "opensearch" {
  name              = "/aws/opensearch/domains/${var.name_prefix}-vector-store" # AWS standard path
  retention_in_days = var.log_retention_days                                    # Log retention policy
  kms_key_id        = var.kms_key_arn                                           # Optional encryption

  tags = merge(var.tags, {
    Purpose = "OpenSearch cluster logging"
    Service = "OpenSearch"
  })
}

# OpenSearch access policy for fine-grained permissions
# Restricts access to authorized IP ranges and actions
data "aws_iam_policy_document" "opensearch_access" {
  statement {
    effect = "Allow" # Allow specified actions

    # Allow all AWS principals (refined by IP conditions)
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    # OpenSearch HTTP actions for full cluster operations
    actions = [
      "es:ESHttpGet",    # Read operations (search, get documents)
      "es:ESHttpPost",   # Create operations (index documents, queries)
      "es:ESHttpPut",    # Update operations (update documents, mappings)
      "es:ESHttpDelete", # Delete operations (delete documents, indices)
      "es:ESHttpHead",   # Metadata operations (check existence)
    ]

    # Apply to all cluster resources and indices
    resources = ["${aws_opensearch_domain.vector_store.arn}/*"]

    # Restrict access to specified IP ranges
    condition {
      test     = "IpAddress"             # IP address condition
      variable = "aws:SourceIp"          # Source IP variable
      values   = var.allowed_cidr_blocks # Allowed CIDR blocks
    }
  }
}

# Apply the access policy to the OpenSearch domain
resource "aws_opensearch_domain_policy" "vector_store" {
  domain_name     = aws_opensearch_domain.vector_store.domain_name      # Target domain
  access_policies = data.aws_iam_policy_document.opensearch_access.json # Policy JSON
}

# =============================================================================
# BEDROCK AI SERVICES (OPTIONAL)
# =============================================================================

# Bedrock model invocation logging configuration (optional)
# Provides detailed logging of AI model usage for monitoring and compliance
resource "aws_bedrock_model_invocation_logging_configuration" "main" {
  count = var.bedrock_logs_bucket != null ? 1 : 0 # Only create if bucket specified

  logging_config {
    # Enable logging for all data types
    embedding_data_delivery_enabled = true # Log embedding model usage
    image_data_delivery_enabled     = true # Log image model usage
    text_data_delivery_enabled      = true # Log text model usage

    # CloudWatch logging configuration
    cloudwatch_config {
      log_group_name = aws_cloudwatch_log_group.bedrock[0].name # Log group name
      role_arn       = aws_iam_role.bedrock_logging[0].arn      # Service role ARN
    }

    # S3 logging configuration for long-term storage
    s3_config {
      bucket_name = var.bedrock_logs_bucket # S3 bucket for log storage
      key_prefix  = "bedrock-logs/"         # Organized prefix for logs
    }
  }
}

# CloudWatch log group for Bedrock AI service logs
resource "aws_cloudwatch_log_group" "bedrock" {
  count = var.bedrock_logs_bucket != null ? 1 : 0 # Only create if bucket specified

  name              = "/aws/bedrock/${var.name_prefix}" # AWS standard log path
  retention_in_days = var.log_retention_days            # Log retention policy
  kms_key_id        = var.kms_key_arn                   # Optional encryption

  tags = merge(var.tags, {
    Purpose = "Bedrock AI service logging"
    Service = "Amazon Bedrock"
  })
}

# IAM role for Bedrock service to write logs to CloudWatch and S3
resource "aws_iam_role" "bedrock_logging" {
  count = var.bedrock_logs_bucket != null ? 1 : 0 # Only create if bucket specified

  name = "${var.name_prefix}-bedrock-logging-role" # Unique role name

  # Trust policy allowing Bedrock service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" # Allow role assumption
        Effect = "Allow"
        Principal = {
          Service = "bedrock.amazonaws.com" # Bedrock service principal
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Purpose = "Bedrock logging permissions"
    Service = "Amazon Bedrock"
  })
}

# IAM policy for Bedrock logging permissions
resource "aws_iam_role_policy" "bedrock_logging" {
  count = var.bedrock_logs_bucket != null ? 1 : 0 # Only create if bucket specified

  name = "${var.name_prefix}-bedrock-logging-policy" # Policy name
  role = aws_iam_role.bedrock_logging[0].id          # Attach to logging role

  # Policy document with specific permissions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        # CloudWatch Logs permissions
        Action = [
          "logs:CreateLogGroup",  # Create log groups
          "logs:CreateLogStream", # Create log streams
          "logs:PutLogEvents"     # Write log events
        ]
        Resource = "${aws_cloudwatch_log_group.bedrock[0].arn}:*" # Specific log group
      },
      {
        Effect = "Allow"
        # S3 permissions for log storage
        Action = [
          "s3:PutObject",        # Upload log files
          "s3:GetBucketLocation" # Get bucket location
        ]
        Resource = [
          "arn:aws:s3:::${var.bedrock_logs_bucket}",  # Bucket itself
          "arn:aws:s3:::${var.bedrock_logs_bucket}/*" # Objects in bucket
        ]
      }
    ]
  })
}

# =============================================================================
# SAGEMAKER CUSTOM MODELS (OPTIONAL)
# =============================================================================

# SageMaker model for custom embedding endpoint (optional)
# Allows deployment of custom embedding models alongside Bedrock
resource "aws_sagemaker_model" "embedding_model" {
  count = var.enable_custom_embedding ? 1 : 0 # Only create if enabled

  name               = "${var.name_prefix}-embedding-model"    # Unique model name
  execution_role_arn = aws_iam_role.sagemaker_execution[0].arn # IAM role for model

  # Primary container configuration
  primary_container {
    image = var.embedding_model_image # Docker image with custom model
    environment = {
      SAGEMAKER_PROGRAM = "inference.py" # Entry point script
    }
  }

  tags = merge(var.tags, {
    Purpose = "Custom embedding model"
    Service = "Amazon SageMaker"
  })
}

# SageMaker endpoint configuration for custom embedding model
resource "aws_sagemaker_endpoint_configuration" "embedding_model" {
  count = var.enable_custom_embedding ? 1 : 0 # Only create if enabled

  name = "${var.name_prefix}-embedding-endpoint-config" # Configuration name

  # Production variant configuration
  production_variants {
    variant_name           = "primary"                                   # Variant identifier
    model_name             = aws_sagemaker_model.embedding_model[0].name # Model reference
    initial_instance_count = 1                                           # Single instance
    instance_type          = var.embedding_instance_type                 # Instance type
  }

  tags = merge(var.tags, {
    Purpose = "Custom embedding endpoint configuration"
    Service = "Amazon SageMaker"
  })
}

# SageMaker endpoint for custom embedding model
resource "aws_sagemaker_endpoint" "embedding_model" {
  count = var.enable_custom_embedding ? 1 : 0 # Only create if enabled

  name                 = "${var.name_prefix}-embedding-endpoint"                      # Endpoint name
  endpoint_config_name = aws_sagemaker_endpoint_configuration.embedding_model[0].name # Config reference

  tags = merge(var.tags, {
    Purpose = "Custom embedding model endpoint"
    Service = "Amazon SageMaker"
  })
}

# IAM role for SageMaker model execution
resource "aws_iam_role" "sagemaker_execution" {
  count = var.enable_custom_embedding ? 1 : 0 # Only create if enabled

  name = "${var.name_prefix}-sagemaker-execution-role" # Unique role name

  # Trust policy allowing SageMaker service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole" # Allow role assumption
        Effect = "Allow"
        Principal = {
          Service = "sagemaker.amazonaws.com" # SageMaker service principal
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Purpose = "SageMaker model execution"
    Service = "Amazon SageMaker"
  })
}

# Attach SageMaker execution policy to the role
resource "aws_iam_role_policy_attachment" "sagemaker_execution" {
  count = var.enable_custom_embedding ? 1 : 0 # Only create if enabled

  policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess" # AWS managed policy
  role       = aws_iam_role.sagemaker_execution[0].name            # Role reference
}