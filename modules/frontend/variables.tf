/*
 * AI Assistant Infrastructure - Frontend Module Variables
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 */

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "domain_name" {
  description = "Custom domain name for the application"
  type        = string
  default     = null
}

variable "api_gateway_url" {
  description = "API Gateway URL for backend integration"
  type        = string
}

variable "cognito_config" {
  description = "Cognito configuration for authentication"
  type        = map(any)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}