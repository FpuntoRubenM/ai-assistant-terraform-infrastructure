/*
 * AI Assistant Infrastructure - Frontend Module Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 */

output "website_url" {
  description = "Website URL (placeholder)"
  value       = var.domain_name != null ? "https://${var.domain_name}" : "https://${var.name_prefix}.s3-website-us-east-1.amazonaws.com"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (placeholder)"
  value       = "${var.name_prefix}-cloudfront-dist"
}