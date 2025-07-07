/*
 * AI Assistant Infrastructure - Variables Configuration
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Centralized variable definitions for the AI Assistant infrastructure
 *              Includes validation rules and default values for all configurable parameters
 *
 * Variable Categories:
 * - Global Configuration (project, environment, region)
 * - Terraform State Management
 * - Networking (VPC, subnets, availability zones)
 * - Database Configuration (Aurora MySQL)
 * - AI Services (OpenSearch, Bedrock models)
 * - Security Settings (CIDR blocks, WAF)
 * - Monitoring and Logging
 */

# =============================================================================
# GLOBAL CONFIGURATION VARIABLES
# =============================================================================

# Global Variables
# AWS region where all resources will be deployed
# Choose region based on latency, compliance, and service availability
variable "aws_region" {
  description = "AWS region for resources deployment (affects latency and compliance)"
  type        = string
  default     = "us-east-1" # Default to N. Virginia for global availability

  # Validation to ensure only valid AWS regions are specified
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in format: us-east-1, eu-west-1, etc."
  }
}

# Project identifier used for resource naming and tagging
# Must follow AWS naming conventions for S3 buckets and other resources
variable "project_name" {
  description = "Unique project identifier (used for resource naming and cost tracking)"
  type        = string
  default     = "ai-assistant"

  # Validation for AWS resource naming compliance
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name)) && length(var.project_name) >= 3 && length(var.project_name) <= 63
    error_message = "Project name must be 3-63 characters, lowercase letters, numbers, and hyphens only."
  }
}

# Environment classification for resource isolation and configuration
# Determines resource sizing, backup policies, and security settings
variable "environment" {
  description = "Environment tier (affects resource sizing and policies)"
  type        = string

  # Strict validation to prevent typos in environment names
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be exactly: dev, staging, or prod."
  }
}

# Resource owner for accountability and cost allocation
# Used in resource tags for governance and billing
variable "owner" {
  description = "Resource owner (team or individual responsible for infrastructure)"
  type        = string

  # Validation to ensure owner is specified
  validation {
    condition     = length(var.owner) > 0
    error_message = "Owner must be specified for resource accountability."
  }
}

# Custom domain name for the AI assistant web application
# If null, will use default CloudFront distribution domain
variable "domain_name" {
  description = "Custom domain name for the application (optional, uses CloudFront default if null)"
  type        = string
  default     = null

  # Validation for domain format when specified
  validation {
    condition     = var.domain_name == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]\\.[a-zA-Z]{2,}$", var.domain_name))
    error_message = "Domain name must be a valid DNS name (e.g., example.com)."
  }
}

# =============================================================================
# TERRAFORM STATE MANAGEMENT
# =============================================================================

# S3 bucket for storing Terraform state file
# Must be created manually before running terraform init
variable "terraform_state_bucket" {
  description = "S3 bucket name for Terraform remote state storage (must exist before deployment)"
  type        = string

  # Validation for S3 bucket naming rules
  validation {
    condition     = can(regex("^[a-z0-9.-]{3,63}$", var.terraform_state_bucket))
    error_message = "S3 bucket name must be 3-63 characters, lowercase letters, numbers, dots, and hyphens only."
  }
}

# DynamoDB table for Terraform state locking to prevent concurrent modifications
# Must be created manually with partition key 'LockID' (String)
variable "terraform_lock_table" {
  description = "DynamoDB table name for Terraform state locking (must exist with LockID partition key)"
  type        = string

  # Validation for DynamoDB table naming
  validation {
    condition     = can(regex("^[a-zA-Z0-9_.-]{3,255}$", var.terraform_lock_table))
    error_message = "DynamoDB table name must be 3-255 characters, letters, numbers, underscores, dots, and hyphens only."
  }
}

# =============================================================================
# NETWORKING CONFIGURATION
# =============================================================================

# VPC CIDR block for the entire network infrastructure
# Provides 65,536 IP addresses for subnets and resources
variable "vpc_cidr" {
  description = "CIDR block for VPC (determines total available IP addresses)"
  type        = string
  default     = "10.0.0.0/16" # RFC 1918 private address space

  # Validation for proper CIDR format and private IP ranges
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0)) && can(regex("^(10\\.|172\\.(1[6-9]|2[0-9]|3[01])\\.|192\\.168\\.)", var.vpc_cidr))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block using private IP ranges (10.x.x.x, 172.16-31.x.x, or 192.168.x.x)."
  }
}

# List of availability zones for multi-AZ deployment
# Ensures high availability and fault tolerance across data centers
variable "availability_zones" {
  description = "List of availability zones for multi-AZ deployment (minimum 2 for HA)"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"] # Three AZs for maximum availability

  # Validation for minimum AZ count for high availability
  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones required for high availability."
  }
}

# Public subnet CIDR blocks for internet-facing resources
# Each subnet provides 256 IP addresses (254 usable)
variable "public_subnets" {
  description = "List of public subnet CIDR blocks for load balancers and NAT gateways"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"] # /24 provides 254 usable IPs each

  # Validation for subnet count matching AZ count
  validation {
    condition     = length(var.public_subnets) >= 2
    error_message = "At least 2 public subnets required for load balancer high availability."
  }
}

# Private subnet CIDR blocks for application and database resources
# Isolated from internet for enhanced security
variable "private_subnets" {
  description = "List of private subnet CIDR blocks for applications and databases"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"] # /24 provides 254 usable IPs each

  # Validation for subnet count matching AZ count
  validation {
    condition     = length(var.private_subnets) >= 2
    error_message = "At least 2 private subnets required for database high availability."
  }
}

# =============================================================================
# DATABASE CONFIGURATION
# =============================================================================

# Aurora MySQL Serverless v2 database configuration
# Automatically scales compute based on application demand
variable "aurora_config" {
  description = "Aurora MySQL Serverless v2 database configuration for AI assistant data"
  type = object({
    engine_version      = string # MySQL engine version
    instance_class      = string # Serverless instance class
    allocated_storage   = number # Minimum storage in GB
    max_capacity        = number # Maximum Aurora Capacity Units (ACUs)
    min_capacity        = number # Minimum Aurora Capacity Units (ACUs)
    backup_retention    = number # Backup retention period in days
    backup_window       = string # Preferred backup window (UTC)
    maintenance_window  = string # Preferred maintenance window (UTC)
    deletion_protection = bool   # Prevent accidental database deletion
  })

  # Production-ready defaults with automatic scaling
  default = {
    engine_version      = "8.0.mysql_aurora.3.02.0" # Latest stable MySQL 8.0
    instance_class      = "db.serverless"           # Serverless v2 class
    allocated_storage   = 20                        # 20 GB minimum storage
    max_capacity        = 2                         # 2 ACUs = ~4 GB RAM, 2 vCPUs
    min_capacity        = 0.5                       # 0.5 ACUs = ~1 GB RAM
    backup_retention    = 7                         # 7 days backup retention
    backup_window       = "03:00-04:00"             # 3-4 AM UTC backup window
    maintenance_window  = "sun:04:00-sun:05:00"     # Sunday 4-5 AM UTC maintenance
    deletion_protection = true                      # Prevent accidental deletion
  }

  # Validation for backup retention period
  validation {
    condition     = var.aurora_config.backup_retention >= 1 && var.aurora_config.backup_retention <= 35
    error_message = "Backup retention must be between 1 and 35 days."
  }

  # Validation for capacity limits
  validation {
    condition     = var.aurora_config.min_capacity >= 0.5 && var.aurora_config.max_capacity <= 128
    error_message = "Aurora capacity must be between 0.5 and 128 ACUs."
  }
}

# =============================================================================
# AI SERVICES CONFIGURATION
# =============================================================================

# OpenSearch cluster configuration for vector embeddings and search
# Stores and searches document embeddings for AI-powered retrieval
variable "opensearch_config" {
  description = "OpenSearch cluster configuration for vector storage and semantic search"
  type = object({
    instance_type  = string # OpenSearch instance type
    instance_count = number # Number of data nodes
    volume_size    = number # EBS volume size per node (GB)
    volume_type    = string # EBS volume type (gp3, gp2, io1)
  })

  # Production-ready defaults for vector search workloads
  default = {
    instance_type  = "t3.small.search" # Cost-effective for development
    instance_count = 2                 # Minimum for high availability
    volume_size    = 20                # 20 GB per node for embeddings
    volume_type    = "gp3"             # Latest generation SSD
  }

  # Validation for minimum cluster size
  validation {
    condition     = var.opensearch_config.instance_count >= 1
    error_message = "OpenSearch cluster must have at least 1 node."
  }

  # Validation for storage size
  validation {
    condition     = var.opensearch_config.volume_size >= 10 && var.opensearch_config.volume_size <= 3000
    error_message = "OpenSearch volume size must be between 10 GB and 3000 GB."
  }
}

# Amazon Bedrock AI models to enable for the assistant
# Includes both high-performance and cost-effective models
variable "bedrock_models" {
  description = "List of Amazon Bedrock model IDs to enable for AI assistant capabilities"
  type        = list(string)

  # Default models: balanced performance and cost
  default = [
    "anthropic.claude-3-sonnet-20240229-v1:0", # High performance for complex tasks
    "anthropic.claude-3-haiku-20240307-v1:0"   # Fast and cost-effective for simple tasks
  ]

  # Validation to ensure at least one model is specified
  validation {
    condition     = length(var.bedrock_models) > 0
    error_message = "At least one Bedrock model must be specified."
  }
}

# =============================================================================
# SECURITY CONFIGURATION
# =============================================================================

# CIDR blocks allowed to access the AI assistant application
# IMPORTANT: Restrict to corporate networks in production for security
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application (restrict to corporate networks in production)"
  type        = list(string)
  default     = ["0.0.0.0/0"] # WARNING: Open to all - restrict in production!

  # Validation for proper CIDR format
  validation {
    condition = alltrue([
      for cidr in var.allowed_cidr_blocks : can(cidrhost(cidr, 0))
    ])
    error_message = "All CIDR blocks must be valid IPv4 CIDR notation (e.g., 10.0.0.0/8)."
  }
}

# Enable AWS Web Application Firewall for additional security
# Protects against common web exploits and DDoS attacks
variable "enable_waf" {
  description = "Enable AWS WAF for web application protection (recommended for production)"
  type        = bool
  default     = true # Always recommended for production workloads
}

# =============================================================================
# MONITORING AND LOGGING CONFIGURATION
# =============================================================================

# Enable detailed CloudWatch monitoring for better observability
# Provides 1-minute metrics instead of default 5-minute intervals
variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for enhanced observability (incurs additional cost)"
  type        = bool
  default     = true # Recommended for production for better insights
}

# CloudWatch log retention period for application and infrastructure logs
# Balances compliance requirements with storage costs
variable "log_retention_days" {
  description = "CloudWatch log retention period in days (affects storage costs and compliance)"
  type        = number
  default     = 30 # 30 days for development, consider 90-365 for production

  # Validation against AWS CloudWatch supported retention periods
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch retention period: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653."
  }
}