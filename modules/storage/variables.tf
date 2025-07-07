/*
 * AI Assistant Infrastructure - Storage Module Variables
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Variable definitions for the storage module
 *              Configures S3 Data Lake and Aurora MySQL database
 */

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

# Naming and identification
variable "name_prefix" {
  description = "Prefix for resource names to ensure uniqueness"
  type        = string
}

variable "random_suffix" {
  description = "Random suffix for globally unique resource names (S3 buckets)"
  type        = string
}

# Network configuration
variable "vpc_id" {
  description = "VPC ID where database resources will be deployed"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for database deployment"
  type        = list(string)
}

# Database configuration
variable "aurora_config" {
  description = "Aurora MySQL database configuration object"
  type = object({
    engine_version      = string
    instance_class      = string
    allocated_storage   = number
    max_capacity        = number
    min_capacity        = number
    backup_retention    = number
    backup_window       = string
    maintenance_window  = string
    deletion_protection = bool
  })
}

# Resource tagging
variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}