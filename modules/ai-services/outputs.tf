/*
 * AI Assistant Infrastructure - AI Services Module Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Output values from the AI services module
 *              Provides references to OpenSearch cluster and optional SageMaker endpoints
 */

# =============================================================================
# OPENSEARCH OUTPUTS
# =============================================================================

# OpenSearch domain endpoint for application connections
output "opensearch_endpoint" {
  description = "OpenSearch domain endpoint for vector search operations"
  value       = aws_opensearch_domain.vector_store.endpoint
  sensitive   = false
}

# OpenSearch domain ARN for IAM policy references
output "opensearch_domain_arn" {
  description = "OpenSearch domain ARN for IAM policy configuration"
  value       = aws_opensearch_domain.vector_store.arn
}

# OpenSearch domain name
output "opensearch_domain_name" {
  description = "OpenSearch domain name for reference"
  value       = aws_opensearch_domain.vector_store.domain_name
}

# OpenSearch client security group for application access
output "opensearch_client_security_group_id" {
  description = "Security group ID for OpenSearch clients"
  value       = aws_security_group.opensearch_client.id
}

# OpenSearch master username and password (sensitive)
output "opensearch_master_username" {
  description = "OpenSearch master username for authentication"
  value       = "admin"
  sensitive   = true
}

output "opensearch_master_password" {
  description = "OpenSearch master password for authentication"
  value       = random_password.opensearch_master.result
  sensitive   = true
}

# =============================================================================
# SAGEMAKER OUTPUTS (OPTIONAL)
# =============================================================================

# SageMaker embedding endpoint name (if enabled)
output "sagemaker_embedding_endpoint_name" {
  description = "SageMaker custom embedding endpoint name"
  value       = var.enable_custom_embedding ? aws_sagemaker_endpoint.embedding_model[0].name : null
}

# SageMaker embedding endpoint ARN (if enabled)
output "sagemaker_embedding_endpoint_arn" {
  description = "SageMaker custom embedding endpoint ARN"
  value       = var.enable_custom_embedding ? aws_sagemaker_endpoint.embedding_model[0].arn : null
}

# =============================================================================
# BEDROCK OUTPUTS (OPTIONAL)
# =============================================================================

# Bedrock logging configuration (if enabled)
output "bedrock_logging_enabled" {
  description = "Whether Bedrock logging is enabled"
  value       = var.bedrock_logs_bucket != null
}

# Bedrock CloudWatch log group (if enabled)
output "bedrock_log_group_name" {
  description = "CloudWatch log group name for Bedrock logs"
  value       = var.bedrock_logs_bucket != null ? aws_cloudwatch_log_group.bedrock[0].name : null
}