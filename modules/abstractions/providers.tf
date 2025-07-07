# Multi-Cloud Provider Abstraction Layer

# Cloud Provider Configuration
variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp)"
  type        = string
  validation {
    condition     = contains(["aws", "azure", "gcp"], var.cloud_provider)
    error_message = "Cloud provider must be aws, azure, or gcp."
  }
}

# Abstract Data Types for Multi-Cloud Resources
variable "database_config" {
  description = "Database configuration abstracted across clouds"
  type = object({
    engine            = string # mysql, postgresql
    version           = string
    tier              = string # small, medium, large, xlarge
    backup_retention  = number
    high_availability = bool
  })
}

variable "ai_model_config" {
  description = "AI model configuration abstracted across clouds"
  type = object({
    text_model      = string # claude, gpt-4, gemini
    embedding_model = string # titan, ada, gecko
    voice_to_text   = bool
    text_to_voice   = bool
  })
}

# Provider-Specific Locals
locals {
  # Database mappings across clouds
  database_mappings = {
    aws = {
      small  = "db.r6g.large"
      medium = "db.r6g.xlarge"
      large  = "db.r6g.2xlarge"
      xlarge = "db.r6g.4xlarge"
    }
    azure = {
      small  = "GP_Gen5_2"
      medium = "GP_Gen5_4"
      large  = "GP_Gen5_8"
      xlarge = "GP_Gen5_16"
    }
    gcp = {
      small  = "db-n1-standard-2"
      medium = "db-n1-standard-4"
      large  = "db-n1-standard-8"
      xlarge = "db-n1-standard-16"
    }
  }

  # AI Service mappings
  ai_service_mappings = {
    aws = {
      text_service      = "bedrock"
      embedding_service = "bedrock"
      voice_service     = "transcribe"
      tts_service       = "polly"
    }
    azure = {
      text_service      = "openai"
      embedding_service = "openai"
      voice_service     = "speech"
      tts_service       = "speech"
    }
    gcp = {
      text_service      = "vertex-ai"
      embedding_service = "vertex-ai"
      voice_service     = "speech-to-text"
      tts_service       = "text-to-speech"
    }
  }

  # Storage mappings
  storage_mappings = {
    aws = {
      object_storage = "s3"
      file_storage   = "efs"
    }
    azure = {
      object_storage = "blob"
      file_storage   = "files"
    }
    gcp = {
      object_storage = "storage"
      file_storage   = "filestore"
    }
  }
}

# Multi-Cloud Module Selection
module "cloud_resources" {
  source = var.cloud_provider == "aws" ? "./aws" : (
    var.cloud_provider == "azure" ? "./azure" : "./gcp"
  )

  # Pass abstracted configuration
  database_tier = local.database_mappings[var.cloud_provider][var.database_config.tier]
  ai_services   = local.ai_service_mappings[var.cloud_provider]
  storage_type  = local.storage_mappings[var.cloud_provider]

  # Common configuration
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}