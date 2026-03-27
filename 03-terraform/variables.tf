# VIX Technologies — Terraform Variables

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "vixplatform"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be development, staging, or production."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "East US"
}

variable "app_service_sku" {
  description = "App Service Plan SKU"
  type        = string
  default     = "B2"
  validation {
    condition     = contains(["B1", "B2", "B3", "P1v3", "P2v3"], var.app_service_sku)
    error_message = "Invalid App Service SKU."
  }
}

variable "db_admin_username" {
  description = "PostgreSQL administrator username"
  type        = string
  sensitive   = true
}

variable "db_admin_password" {
  description = "PostgreSQL administrator password"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.db_admin_password) >= 12
    error_message = "Database password must be at least 12 characters."
  }
}

variable "anthropic_api_key" {
  description = "Anthropic Claude API key"
  type        = string
  sensitive   = true
}

variable "supabase_url" {
  description = "Supabase project URL"
  type        = string
}

variable "supabase_anon_key" {
  description = "Supabase anonymous key"
  type        = string
  sensitive   = true
}