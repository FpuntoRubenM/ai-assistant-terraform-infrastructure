/*
 * AI Assistant Infrastructure - Compute Module (Placeholder)
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Compute infrastructure placeholder for the AI assistant
 *              This module will contain ECS Fargate tasks and Lambda functions
 *              Currently implemented as placeholder for infrastructure validation
 */

# =============================================================================
# PLACEHOLDER RESOURCES
# =============================================================================

# CloudWatch Log Group for application logs
resource "aws_cloudwatch_log_group" "app_logs" {
  name              = "/aws/applications/${var.name_prefix}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-app-logs"
    Purpose = "Application logging placeholder"
  })
}

# Data sources for external references
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}