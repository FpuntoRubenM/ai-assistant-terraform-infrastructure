/*
 * AI Assistant Infrastructure - Compute Module Variables
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 */

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for compute resources"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for compute resources"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs for compute resources"
  type        = list(string)
}

variable "aurora_endpoint" {
  description = "Aurora database endpoint"
  type        = string
}

variable "s3_bucket_names" {
  description = "S3 bucket names for data access"
  type        = map(string)
}

variable "opensearch_endpoint" {
  description = "OpenSearch endpoint for search operations"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}