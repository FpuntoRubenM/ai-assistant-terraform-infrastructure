/*
 * AI Assistant Infrastructure - AI Services Module Variables
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Variable definitions for the AI services module
 *              Configures OpenSearch, Bedrock, and optional SageMaker services
 */

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

# Naming and identification
variable "name_prefix" {
  description = "Prefix for resource names to ensure uniqueness"
  type        = string
}

# Network configuration
variable "vpc_id" {
  description = "VPC ID where OpenSearch cluster will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for OpenSearch deployment"
  type        = list(string)
}

# OpenSearch configuration
variable "opensearch_config" {
  description = "OpenSearch cluster configuration object"
  type = object({
    instance_type  = string
    instance_count = number
    volume_size    = number
    volume_type    = string
  })
}

# Resource tagging
variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# OPTIONAL VARIABLES WITH DEFAULTS
# =============================================================================

# Security configuration
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access OpenSearch cluster"
  type        = list(string)
  default     = ["10.0.0.0/8"]
}

# Logging configuration
variable "log_retention_days" {
  description = "CloudWatch log retention period in days"
  type        = number
  default     = 30
}

# Encryption configuration
variable "kms_key_arn" {
  description = "KMS key ARN for encrypting logs (optional)"
  type        = string
  default     = null
}

# Bedrock configuration
variable "bedrock_logs_bucket" {
  description = "S3 bucket name for Bedrock logs (optional)"
  type        = string
  default     = null
}

# SageMaker configuration (optional)
variable "enable_custom_embedding" {
  description = "Enable custom SageMaker embedding model endpoint"
  type        = bool
  default     = false
}

variable "embedding_model_image" {
  description = "Docker image URI for custom embedding model"
  type        = string
  default     = ""
}

variable "embedding_instance_type" {
  description = "Instance type for SageMaker embedding endpoint"
  type        = string
  default     = "ml.t3.medium"
}