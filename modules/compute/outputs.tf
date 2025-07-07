/*
 * AI Assistant Infrastructure - Compute Module Outputs
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 */

output "lambda_functions" {
  description = "Lambda function information (placeholder)"
  value = {
    app_processor = {
      name = "${var.name_prefix}-app-processor"
      arn  = "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${var.name_prefix}-app-processor"
    }
  }
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.app_logs.name
}