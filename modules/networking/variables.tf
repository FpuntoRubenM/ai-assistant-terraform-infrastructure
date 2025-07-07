/*
 * AI Assistant Infrastructure - Networking Module Variables
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Variable definitions for the networking module
 *              Configures VPC, subnets, and availability zones
 */

# =============================================================================
# REQUIRED VARIABLES
# =============================================================================

# Naming and identification
variable "name_prefix" {
  description = "Prefix for resource names to ensure uniqueness"
  type        = string
}

# VPC configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Availability zones for multi-AZ deployment
variable "availability_zones" {
  description = "List of availability zones for subnet deployment"
  type        = list(string)
}

# Public subnet configuration
variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

# Private subnet configuration
variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

# Resource tagging
variable "tags" {
  description = "Map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}