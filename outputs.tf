/*
 * AI Assistant Infrastructure - Main Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Output values from the main AI assistant infrastructure
 *              Provides essential information for connecting to deployed services
 */

# =============================================================================
# NETWORKING OUTPUTS
# =============================================================================

output "vpc_id" {
  description = "ID of the created VPC"
  value       = module.networking.vpc_id
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnets
}

# =============================================================================
# STORAGE OUTPUTS
# =============================================================================

output "aurora_endpoint" {
  description = "Aurora database cluster endpoint"
  value       = module.storage.aurora_endpoint
  sensitive   = false
}

output "aurora_reader_endpoint" {
  description = "Aurora database reader endpoint"
  value       = module.storage.aurora_reader_endpoint
  sensitive   = false
}

output "s3_bucket_names" {
  description = "Map of S3 bucket names for the data lake"
  value       = module.storage.s3_bucket_names
}

output "aurora_master_user_secret_arn" {
  description = "ARN of Aurora master user secret in Secrets Manager"
  value       = module.storage.aurora_master_user_secret_arn
  sensitive   = true
}

# =============================================================================
# AI SERVICES OUTPUTS
# =============================================================================

output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint for vector search"
  value       = module.ai_services.opensearch_endpoint
  sensitive   = false
}

output "opensearch_master_username" {
  description = "OpenSearch master username"
  value       = module.ai_services.opensearch_master_username
  sensitive   = true
}

output "opensearch_master_password" {
  description = "OpenSearch master password"
  value       = module.ai_services.opensearch_master_password
  sensitive   = true
}

# =============================================================================
# SECURITY OUTPUTS
# =============================================================================

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID for authentication"
  value       = module.security.cognito_user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID for web application"
  value       = module.security.cognito_user_pool_client_id
}

output "cognito_user_pool_domain" {
  description = "Cognito User Pool domain for hosted UI"
  value       = module.security.cognito_user_pool_domain
}

output "cognito_config" {
  description = "Complete Cognito configuration for frontend applications"
  value       = module.security.cognito_config
}

# =============================================================================
# DEPLOYMENT INFORMATION
# =============================================================================

output "deployment_info" {
  description = "Key deployment information and connection details"
  value = {
    # Infrastructure metadata
    project_name = var.project_name
    environment  = var.environment
    aws_region   = var.aws_region
    deployed_by  = "Ruben Martin"
    deployed_on  = "2025-07-03"
    
    # Key endpoints
    database_endpoint    = module.storage.aurora_endpoint
    search_endpoint     = module.ai_services.opensearch_endpoint
    auth_domain         = module.security.cognito_user_pool_domain
    
    # Security
    vpc_id              = module.networking.vpc_id
    waf_enabled         = var.enable_waf
    
    # Storage
    data_lake_buckets   = keys(module.storage.s3_bucket_names)
    
    # Next steps
    next_steps = [
      "1. Configure DNS records if using custom domain",
      "2. Set up monitoring dashboards in CloudWatch",
      "3. Configure backup policies for critical data",
      "4. Review security group rules for production",
      "5. Set up CI/CD pipelines for application deployment"
    ]
  }
}

# =============================================================================
# CONNECTION STRINGS (SENSITIVE)
# =============================================================================

output "connection_strings" {
  description = "Database and service connection information"
  value = {
    aurora_endpoint     = module.storage.aurora_endpoint
    aurora_database     = module.storage.aurora_database_name
    aurora_username     = module.storage.aurora_master_username
    opensearch_endpoint = module.ai_services.opensearch_endpoint
    opensearch_username = module.ai_services.opensearch_master_username
  }
  sensitive = true
}