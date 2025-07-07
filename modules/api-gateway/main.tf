/*
 * AI Assistant Infrastructure - API Gateway Module (Placeholder)
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: API Gateway infrastructure placeholder for the AI assistant
 */

# =============================================================================
# PLACEHOLDER RESOURCES
# =============================================================================

# CloudWatch Log Group for API Gateway logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.name_prefix}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-api-logs"
    Purpose = "API Gateway logging placeholder"
  })
}

# Data sources
data "aws_region" "current" {}