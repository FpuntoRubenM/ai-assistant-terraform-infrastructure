/*
 * AI Assistant Infrastructure - Storage Module Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Output values from the storage module
 *              Provides references to S3 buckets and Aurora database
 */

# =============================================================================
# S3 DATA LAKE OUTPUTS
# =============================================================================

# S3 bucket names for application reference
output "s3_bucket_names" {
  description = "Map of S3 bucket names organized by purpose"
  value = {
    raw_documents       = aws_s3_bucket.data_lake["raw-documents"].id
    processed_documents = aws_s3_bucket.data_lake["processed-documents"].id
    embeddings          = aws_s3_bucket.data_lake["embeddings"].id
    user_uploads        = aws_s3_bucket.data_lake["user-uploads"].id
    generated_documents = aws_s3_bucket.data_lake["generated-documents"].id
    backup              = aws_s3_bucket.data_lake["backup"].id
  }
}

# S3 bucket ARNs for IAM policy references
output "s3_bucket_arns" {
  description = "Map of S3 bucket ARNs for IAM policy configuration"
  value = {
    raw_documents       = aws_s3_bucket.data_lake["raw-documents"].arn
    processed_documents = aws_s3_bucket.data_lake["processed-documents"].arn
    embeddings          = aws_s3_bucket.data_lake["embeddings"].arn
    user_uploads        = aws_s3_bucket.data_lake["user-uploads"].arn
    generated_documents = aws_s3_bucket.data_lake["generated-documents"].arn
    backup              = aws_s3_bucket.data_lake["backup"].arn
  }
}

# =============================================================================
# AURORA DATABASE OUTPUTS
# =============================================================================

# Aurora cluster endpoint for application connections
output "aurora_endpoint" {
  description = "Aurora cluster endpoint for database connections"
  value       = aws_rds_cluster.aurora.endpoint
  sensitive   = false
}

# Aurora cluster reader endpoint for read-only queries
output "aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint for read-only database connections"
  value       = aws_rds_cluster.aurora.reader_endpoint
  sensitive   = false
}

# Aurora cluster identifier
output "aurora_cluster_id" {
  description = "Aurora cluster identifier for reference"
  value       = aws_rds_cluster.aurora.cluster_identifier
}

# Aurora database name
output "aurora_database_name" {
  description = "Aurora database name for application configuration"
  value       = aws_rds_cluster.aurora.database_name
}

# Aurora master username
output "aurora_master_username" {
  description = "Aurora master username for application configuration"
  value       = aws_rds_cluster.aurora.master_username
  sensitive   = true
}

# Aurora master user secret ARN (managed password)
output "aurora_master_user_secret_arn" {
  description = "ARN of the Aurora master user secret in Secrets Manager"
  value       = aws_rds_cluster.aurora.master_user_secret[0].secret_arn
  sensitive   = true
}

# =============================================================================
# SECURITY OUTPUTS
# =============================================================================

# Aurora client security group for application access
output "aurora_client_security_group_id" {
  description = "Security group ID for Aurora database clients"
  value       = aws_security_group.aurora_client.id
}

# KMS key for storage encryption
output "storage_kms_key_id" {
  description = "KMS key ID for storage encryption"
  value       = aws_kms_key.storage.id
}

# KMS key ARN for storage encryption
output "storage_kms_key_arn" {
  description = "KMS key ARN for storage encryption"
  value       = aws_kms_key.storage.arn
}