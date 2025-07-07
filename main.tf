/*
 * AI Assistant Infrastructure - Main Configuration
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Enterprise AI Assistant Infrastructure using Terraform
 *              Deploys a scalable, secure AI assistant with voice/text capabilities,
 *              document processing, and multi-user access control
 *
 * Architecture Components:
 * - VPC with public/private subnets
 * - Aurora MySQL Serverless v2 database
 * - S3 Data Lake for document storage
 * - OpenSearch for vector embeddings
 * - Lambda functions for serverless processing
 * - ECS Fargate for containerized services
 * - API Gateway with Cognito authentication
 * - CloudFront distribution for web frontend
 * 
 * Security Features:
 * - End-to-end encryption with KMS
 * - WAF protection
 * - VPC security groups
 * - IAM roles with least privilege
 * - Secrets Manager for credentials
 */

# AI Assistant Infrastructure - Main Configuration
# Terraform configuration block
# Defines required Terraform version and provider versions for consistency
terraform {
  required_version = ">= 1.5" # Minimum Terraform version for modern features

  # Provider version constraints to ensure compatibility
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # AWS provider v5.x for latest features
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1" # Random provider for generating unique values
    }
  }

  # Backend configuration - uncomment and configure for production
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "ai-assistant/terraform.tfstate" 
  #   region         = "us-east-1"
  #   encrypt        = true
  #   dynamodb_table = "your-terraform-locks"
  # }
}

# AWS Provider configuration
# Sets default region and applies consistent tags to all resources
provider "aws" {
  region = var.aws_region # Primary AWS region for resource deployment

  # Default tags applied to all AWS resources for governance and cost tracking
  default_tags {
    tags = {
      Project     = var.project_name # Project identifier for resource grouping
      Environment = var.environment  # Environment (dev/staging/prod) for lifecycle management
      ManagedBy   = "terraform"      # Indicates infrastructure is managed by Terraform
      Owner       = var.owner        # Resource owner for accountability
      Author      = "Ruben Martin"   # Original infrastructure author
      CreatedDate = "2025-07-03"     # Infrastructure creation date
    }
  }
}

# Random suffix generator for globally unique resource names
# Prevents naming conflicts when deploying multiple instances
resource "random_id" "suffix" {
  byte_length = 4 # Generates 8-character hex string
}

# Local values for consistent naming and tagging across all resources
locals {
  # Standardized naming prefix: project-environment format
  name_prefix = "${var.project_name}-${var.environment}"

  # Common tags applied to all resources for governance
  common_tags = {
    Project     = var.project_name # Project identification
    Environment = var.environment  # Environment classification
    ManagedBy   = "terraform"      # Infrastructure management tool
    Owner       = var.owner        # Resource ownership
    Author      = "Ruben Martin"   # Infrastructure architect
    CreatedDate = "2025-07-03"     # Creation timestamp
    Purpose     = "AI Assistant"   # Resource purpose
  }
}

# =============================================================================
# CORE INFRASTRUCTURE MODULES
# =============================================================================

# Networking Module - VPC, Subnets, Internet Gateway, NAT Gateways
# Creates the foundational network infrastructure for the AI assistant
module "networking" {
  source = "./modules/networking" # Path to networking module

  # Naming configuration
  name_prefix = local.name_prefix # Consistent resource naming
  vpc_cidr    = var.vpc_cidr      # VPC CIDR block for IP addressing

  # Multi-AZ deployment for high availability
  availability_zones = var.availability_zones # List of AZs to deploy across
  public_subnets     = var.public_subnets     # Public subnet CIDRs for load balancers
  private_subnets    = var.private_subnets    # Private subnet CIDRs for application servers

  # Resource tagging
  tags = local.common_tags # Apply consistent tags
}

# Security Module - Cognito, IAM Roles, Security Groups, WAF
# Handles authentication, authorization, and network security
module "security" {
  source = "./modules/security" # Path to security module

  # Configuration
  name_prefix     = local.name_prefix                  # Consistent resource naming
  vpc_id          = module.networking.vpc_id           # VPC reference from networking module
  vpc_cidr_block  = module.networking.vpc_cidr_block   # VPC CIDR for security groups
  
  # Application configuration
  domain_name = var.domain_name # Custom domain for Cognito callbacks
  enable_waf  = var.enable_waf  # WAF configuration

  # Resource tagging
  tags = local.common_tags # Apply consistent tags
}

# Storage Module - S3 Data Lake, Aurora MySQL Database
# Manages structured and unstructured data storage for the AI assistant
module "storage" {
  source = "./modules/storage" # Path to storage module

  # Configuration
  name_prefix     = local.name_prefix                 # Consistent resource naming
  random_suffix   = random_id.suffix.hex              # Unique suffix for global resources
  vpc_id          = module.networking.vpc_id          # VPC reference for database security
  private_subnets = module.networking.private_subnets # Private subnets for database

  # Database configuration
  aurora_config = var.aurora_config # Aurora MySQL Serverless v2 settings

  # Resource tagging
  tags = local.common_tags # Apply consistent tags
}

# AI Services Module - OpenSearch, Bedrock, ML Services
# Provides AI/ML capabilities including vector search and language models
module "ai_services" {
  source = "./modules/ai-services" # Path to AI services module

  # Configuration
  name_prefix     = local.name_prefix                 # Consistent resource naming
  vpc_id          = module.networking.vpc_id          # VPC reference for OpenSearch security
  private_subnets = module.networking.private_subnets # Private subnets for OpenSearch

  # Vector search configuration
  opensearch_config = var.opensearch_config # OpenSearch cluster settings

  # Security configuration
  allowed_cidr_blocks = var.allowed_cidr_blocks # CIDR blocks for access
  
  # Logging configuration
  log_retention_days = var.log_retention_days # Log retention policy
  kms_key_arn       = module.storage.storage_kms_key_arn # KMS key for encryption

  # Resource tagging
  tags = local.common_tags # Apply consistent tags
}

# Compute Module - ECS Fargate, Lambda Functions
# Handles application logic and document processing workloads
module "compute" {
  source = "./modules/compute" # Path to compute module

  # Configuration
  name_prefix     = local.name_prefix                 # Consistent resource naming
  vpc_id          = module.networking.vpc_id          # VPC reference for compute resources
  private_subnets = module.networking.private_subnets # Private subnets for containers

  # Security group references from security module
  security_group_ids = [
    module.security.ecs_security_group_id,   # ECS container security group
    module.security.lambda_security_group_id # Lambda function security group
  ]

  # Data layer connections
  aurora_endpoint     = module.storage.aurora_endpoint         # Database connection endpoint
  s3_bucket_names     = module.storage.s3_bucket_names         # S3 bucket references
  opensearch_endpoint = module.ai_services.opensearch_endpoint # Vector search endpoint

  # Resource tagging
  tags = local.common_tags # Apply consistent tags
}

# API Gateway Module - REST API, Authentication, Rate Limiting
# Provides secure API endpoints for the AI assistant frontend
module "api_gateway" {
  source = "./modules/api-gateway" # Path to API Gateway module

  # Configuration
  name_prefix = local.name_prefix # Consistent resource naming

  # Backend integration
  lambda_functions      = module.compute.lambda_functions       # Lambda function integrations
  cognito_user_pool_arn = module.security.cognito_user_pool_arn # Authentication provider

  # Resource tagging
  tags = local.common_tags # Apply consistent tags
}

# Frontend Module - S3 Static Website, CloudFront CDN
# Hosts and distributes the AI assistant web application
module "frontend" {
  source = "./modules/frontend" # Path to frontend module

  # Configuration
  name_prefix = local.name_prefix # Consistent resource naming
  domain_name = var.domain_name   # Custom domain for the application

  # Backend integration
  api_gateway_url = module.api_gateway.api_gateway_url # API endpoint for frontend
  cognito_config  = module.security.cognito_config     # Authentication configuration

  # Resource tagging
  tags = local.common_tags # Apply consistent tags
}