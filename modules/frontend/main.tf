/*
 * AI Assistant Infrastructure - Frontend Module (Placeholder)
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Frontend infrastructure placeholder for the AI assistant
 */

# =============================================================================
# PLACEHOLDER RESOURCES
# =============================================================================

# CloudWatch Log Group for frontend logs
resource "aws_cloudwatch_log_group" "frontend_logs" {
  name              = "/aws/frontend/${var.name_prefix}"
  retention_in_days = 30

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-frontend-logs"
    Purpose = "Frontend logging placeholder"
  })
}