/*
 * AI Assistant Infrastructure - API Gateway Module Variables
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 */

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "lambda_functions" {
  description = "Lambda function information"
  type        = map(any)
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN for authorization"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}