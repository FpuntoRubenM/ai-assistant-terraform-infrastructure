/*
 * AI Assistant Infrastructure - Security Module Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Output values from the security module
 *              Provides security group IDs, IAM roles, and Cognito configuration
 */

# =============================================================================
# COGNITO OUTPUTS
# =============================================================================

# Cognito User Pool ARN for API Gateway authorization
output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool for API Gateway authorization"
  value       = aws_cognito_user_pool.main.arn
}

# Cognito User Pool ID
output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

# Cognito User Pool Client ID
output "cognito_user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.web_client.id
}

# Cognito User Pool Domain
output "cognito_user_pool_domain" {
  description = "Domain of the Cognito User Pool for hosted UI"
  value       = aws_cognito_user_pool_domain.main.domain
}

# Cognito configuration object for frontend
output "cognito_config" {
  description = "Complete Cognito configuration for frontend applications"
  value = {
    user_pool_id        = aws_cognito_user_pool.main.id
    user_pool_client_id = aws_cognito_user_pool_client.web_client.id
    user_pool_domain    = aws_cognito_user_pool_domain.main.domain
    region              = data.aws_region.current.name
  }
}

# =============================================================================
# IAM OUTPUTS
# =============================================================================

# ECS Task Role ARN
output "ecs_task_role_arn" {
  description = "ARN of the IAM role for ECS tasks"
  value       = aws_iam_role.ecs_task_role.arn
}

# Lambda Role ARN
output "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda functions"
  value       = aws_iam_role.lambda_role.arn
}

# =============================================================================
# SECURITY GROUP OUTPUTS
# =============================================================================

# ECS Security Group ID
output "ecs_security_group_id" {
  description = "Security group ID for ECS tasks"
  value       = aws_security_group.ecs.id
}

# Lambda Security Group ID
output "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  value       = aws_security_group.lambda.id
}

# Application Load Balancer Security Group ID
output "alb_security_group_id" {
  description = "Security group ID for Application Load Balancer"
  value       = aws_security_group.alb.id
}

# =============================================================================
# WAF OUTPUTS
# =============================================================================

# WAF Web ACL ARN (if enabled)
output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL (if enabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].arn : null
}

# WAF Web ACL ID (if enabled)
output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL (if enabled)"
  value       = var.enable_waf ? aws_wafv2_web_acl.main[0].id : null
}

# Data source for current AWS region
data "aws_region" "current" {}