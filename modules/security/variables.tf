/*
 * AI Assistant Infrastructure - Security Module Variables
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Variable definitions for the security module
 *              Configures authentication, authorization, and network security
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
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "vpc_cidr_block" {
  description = "VPC CIDR block for security group rules"
  type        = string
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

# Domain configuration
variable "domain_name" {
  description = "Custom domain name for the application (used in Cognito callbacks)"
  type        = string
  default     = null
}

# WAF configuration
variable "enable_waf" {
  description = "Enable AWS WAF for web application protection"
  type        = bool
  default     = true
}