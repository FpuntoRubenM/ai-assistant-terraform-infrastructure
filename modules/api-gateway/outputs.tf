/*
 * AI Assistant Infrastructure - API Gateway Module Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 */

output "api_gateway_url" {
  description = "API Gateway URL (placeholder)"
  value       = "https://api.${var.name_prefix}.${data.aws_region.current.name}.amazonaws.com"
}

output "api_gateway_id" {
  description = "API Gateway ID (placeholder)"
  value       = "${var.name_prefix}-api-gateway"
}