# Development Environment Configuration
# Author: Ruben Martin
# Date: 2025-07-03

project_name = "ai-assistant"
environment  = "dev"
owner        = "DevOps Team"

# AWS Configuration
aws_region = "us-east-1"

# Domain Configuration (opcional para desarrollo)
domain_name = null

# Terraform State (ajustar según tu configuración)
terraform_state_bucket = "my-terraform-state-dev"
terraform_lock_table   = "my-terraform-locks"

# Networking - Rangos más pequeños para desarrollo
vpc_cidr           = "10.1.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
public_subnets     = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets    = ["10.1.10.0/24", "10.1.20.0/24"]

# Aurora Database Configuration - Configuración mínima para desarrollo
aurora_config = {
  engine_version      = "8.0.mysql_aurora.3.02.0"
  instance_class      = "db.serverless"
  allocated_storage   = 20
  max_capacity        = 1      # Menor capacidad para desarrollo
  min_capacity        = 0.5    # Mínimo para ahorrar costos
  backup_retention    = 3      # Menos días de backup
  backup_window       = "03:00-04:00"
  maintenance_window  = "sun:04:00-sun:05:00"
  deletion_protection = false  # Permitir eliminación en desarrollo
}

# OpenSearch Configuration - Configuración mínima
opensearch_config = {
  instance_type  = "t3.small.search"
  instance_count = 1               # Un solo nodo para desarrollo
  volume_size    = 20              # Menor almacenamiento
  volume_type    = "gp3"
}

# AI Services - Modelos básicos para desarrollo
bedrock_models = [
  "anthropic.claude-3-haiku-20240307-v1:0"  # Modelo más económico
]

# Security - Más permisivo para desarrollo (ajustar según necesidades)
allowed_cidr_blocks = [
  "0.0.0.0/0"  # ADVERTENCIA: Abierto a todo - solo para desarrollo
]
enable_waf = false  # Deshabilitado para ahorrar costos en desarrollo

# Monitoring - Configuración básica
enable_detailed_monitoring = false  # Ahorrar costos en desarrollo
log_retention_days         = 7      # Menor retención de logs