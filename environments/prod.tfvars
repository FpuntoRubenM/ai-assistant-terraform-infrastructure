# Production Environment Configuration
project_name = "ai-assistant"
environment  = "prod"
owner        = "devops-team"

# AWS Configuration
aws_region = "us-east-1"

# Domain Configuration
domain_name = "ai-assistant.company.com"

# Terraform State
terraform_state_bucket = "company-terraform-state-prod"
terraform_lock_table   = "company-terraform-locks"

# Networking
vpc_cidr           = "10.1.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnets    = ["10.1.10.0/24", "10.1.20.0/24", "10.1.30.0/24"]

# Aurora Database Configuration
aurora_config = {
  engine_version      = "8.0.mysql_aurora.3.02.0"
  instance_class      = "db.serverless"
  allocated_storage   = 100
  max_capacity        = 16
  min_capacity        = 2
  backup_retention    = 30
  backup_window       = "03:00-04:00"
  maintenance_window  = "sun:04:00-sun:05:00"
  deletion_protection = true
}

# OpenSearch Configuration
opensearch_config = {
  instance_type  = "t3.medium.search"
  instance_count = 3
  volume_size    = 100
  volume_type    = "gp3"
}

# AI Services
bedrock_models = [
  "anthropic.claude-3-sonnet-20240229-v1:0",
  "anthropic.claude-3-haiku-20240307-v1:0",
  "cohere.embed-english-v3",
  "amazon.titan-embed-text-v1"
]

# Security
allowed_cidr_blocks = [
  "10.0.0.0/8",    # Internal corporate network
  "203.0.113.0/24" # Office public IP range
]
enable_waf = true

# Monitoring
enable_detailed_monitoring = true
log_retention_days         = 90