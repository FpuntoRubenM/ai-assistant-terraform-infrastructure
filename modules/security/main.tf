/*
 * AI Assistant Infrastructure - Security Module
 * 
 * Author: Ruben Martin
 * Date: 2025-07-03
 * Description: Security infrastructure for the AI assistant
 *              Handles authentication, authorization, and network security
 *
 * Components:
 * - Amazon Cognito User Pool for user authentication
 * - IAM roles and policies for service permissions
 * - Security groups for network access control
 * - AWS WAF for web application protection
 *
 * Security Features:
 * - Multi-factor authentication support
 * - Fine-grained IAM permissions
 * - Network segmentation with security groups
 * - Web application firewall protection
 */

# =============================================================================
# COGNITO USER AUTHENTICATION
# =============================================================================

# Cognito User Pool for AI assistant user authentication
# Provides secure user registration, login, and session management
resource "aws_cognito_user_pool" "main" {
  name = "${var.name_prefix}-user-pool"

  # Password policy for strong security
  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  # User attributes and verification
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Account recovery settings
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  # Admin create user configuration
  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = "Welcome to AI Assistant {username}! Your temporary password is {password}. Use {####} for verification."
      email_subject = "Welcome to AI Assistant"
    }
  }

  # Device configuration
  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = false
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-user-pool"
    Purpose = "AI assistant user authentication"
  })
}

# Cognito User Pool Client for web application
resource "aws_cognito_user_pool_client" "web_client" {
  name         = "${var.name_prefix}-web-client"
  user_pool_id = aws_cognito_user_pool.main.id

  # OAuth configuration
  generate_secret = false
  supported_identity_providers = ["COGNITO"]
  
  callback_urls = [
    "https://localhost:3000/callback",
    "https://${var.domain_name != null ? var.domain_name : "example.com"}/callback"
  ]
  
  logout_urls = [
    "https://localhost:3000/",
    "https://${var.domain_name != null ? var.domain_name : "example.com"}/"
  ]

  allowed_oauth_flows = ["code"]
  allowed_oauth_scopes = ["email", "openid", "profile"]
  allowed_oauth_flows_user_pool_client = true

  # Token validity periods
  id_token_validity     = 60   # 1 hour
  access_token_validity = 60   # 1 hour
  refresh_token_validity = 30  # 30 days

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # Prevent user existence errors for security
  prevent_user_existence_errors = "ENABLED"

  # Read and write attributes
  read_attributes = [
    "email",
    "email_verified",
    "name",
    "family_name",
    "given_name"
  ]

  write_attributes = [
    "email",
    "name",
    "family_name",
    "given_name"
  ]
}

# Cognito User Pool Domain for hosted UI
resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.name_prefix}-auth-${random_id.auth_suffix.hex}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Random suffix for unique domain name
resource "random_id" "auth_suffix" {
  byte_length = 4
}

# =============================================================================
# IAM ROLES AND POLICIES
# =============================================================================

# IAM role for ECS tasks
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name_prefix}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-ecs-task-role"
    Purpose = "ECS task execution permissions"
  })
}

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.name_prefix}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-lambda-role"
    Purpose = "Lambda function execution permissions"
  })
}

# IAM policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# IAM policy for Lambda VPC access
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# =============================================================================
# SECURITY GROUPS
# =============================================================================

# Security group for ECS tasks
resource "aws_security_group" "ecs" {
  name_prefix = "${var.name_prefix}-ecs-"
  vpc_id      = var.vpc_id
  description = "Security group for ECS tasks"

  # Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "HTTP from VPC"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "HTTPS from VPC"
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-ecs-sg"
    Purpose = "ECS task network security"
  })
}

# Security group for Lambda functions
resource "aws_security_group" "lambda" {
  name_prefix = "${var.name_prefix}-lambda-"
  vpc_id      = var.vpc_id
  description = "Security group for Lambda functions"

  # Outbound rules only (Lambda typically doesn't accept inbound connections)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-lambda-sg"
    Purpose = "Lambda function network security"
  })
}

# Security group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.name_prefix}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  # Inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from internet"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from internet"
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-alb-sg"
    Purpose = "Load balancer network security"
  })
}

# =============================================================================
# AWS WAF (OPTIONAL)
# =============================================================================

# WAF Web ACL for application protection
resource "aws_wafv2_web_acl" "main" {
  count = var.enable_waf ? 1 : 0

  name  = "${var.name_prefix}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rule Sets
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsRuleSetMetric"
      sampled_requests_enabled   = true
    }
  }

  # Rate limiting rule
  rule {
    name     = "RateLimitRule"
    priority = 3

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "RateLimitRuleMetric"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}WebAcl"
    sampled_requests_enabled   = true
  }

  tags = merge(var.tags, {
    Name    = "${var.name_prefix}-web-acl"
    Purpose = "Web application firewall protection"
  })
}