# VIX Technologies — Infrastructure as Code
# Terraform configuration for Azure cloud infrastructure

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Remote state storage (Azure Blob Storage)
  backend "azurerm" {
    resource_group_name  = "vix-terraform-state"
    storage_account_name = "vixtfstate"
    container_name       = "tfstate"
    key                  = "vix-platform.tfstate"
  }
}

# Configure Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

# ─── Random suffix for unique names ──────────────────────────
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ─── Resource Group ───────────────────────────────────────────
resource "azurerm_resource_group" "vix" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = local.common_tags
}

# ─── Virtual Network ──────────────────────────────────────────
resource "azurerm_virtual_network" "vix" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vix.location
  resource_group_name = azurerm_resource_group.vix.name

  tags = local.common_tags
}

# ─── Subnets ──────────────────────────────────────────────────
resource "azurerm_subnet" "app" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.vix.name
  virtual_network_name = azurerm_virtual_network.vix.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "database" {
  name                 = "subnet-database"
  resource_group_name  = azurerm_resource_group.vix.name
  virtual_network_name = azurerm_virtual_network.vix.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

# ─── Container Registry ───────────────────────────────────────
resource "azurerm_container_registry" "vix" {
  name                = "acr${var.project_name}${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.vix.name
  location            = azurerm_resource_group.vix.location
  sku                 = "Standard"
  admin_enabled       = true

  tags = local.common_tags
}

# ─── App Service Plan ─────────────────────────────────────────
resource "azurerm_service_plan" "vix" {
  name                = "asp-${var.project_name}-${var.environment}"
  resource_group_name = azurerm_resource_group.vix.name
  location            = azurerm_resource_group.vix.location
  os_type             = "Linux"
  sku_name            = var.app_service_sku

  tags = local.common_tags
}

# ─── App Service (VIX Platform) ───────────────────────────────
resource "azurerm_linux_web_app" "vix_platform" {
  name                = "app-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.vix.name
  location            = azurerm_service_plan.vix.location
  service_plan_id     = azurerm_service_plan.vix.id
  https_only          = true

  site_config {
    always_on        = true
    http2_enabled    = true
    minimum_tls_version = "1.2"

    application_stack {
      docker_image_name        = "${azurerm_container_registry.vix.login_server}/vix-platform:latest"
      docker_registry_url      = "https://${azurerm_container_registry.vix.login_server}"
      docker_registry_username = azurerm_container_registry.vix.admin_username
      docker_registry_password = azurerm_container_registry.vix.admin_password
    }

    health_check_path = "/"
  }

  app_settings = {
    "WEBSITES_PORT"                   = "3000"
    "NEXT_PUBLIC_SITE_URL"            = "https://vixtech.co.ke"
    "NODE_ENV"                        = "production"
    "NEXT_TELEMETRY_DISABLED"         = "1"
    "ANTHROPIC_API_KEY"               = var.anthropic_api_key
    "NEXT_PUBLIC_SUPABASE_URL"        = var.supabase_url
    "NEXT_PUBLIC_SUPABASE_ANON_KEY"   = var.supabase_anon_key
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# ─── PostgreSQL Flexible Server ───────────────────────────────
resource "azurerm_postgresql_flexible_server" "vix" {
  name                   = "psql-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.vix.name
  location               = azurerm_resource_group.vix.location
  version                = "15"
  delegated_subnet_id    = azurerm_subnet.database.id
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password
  zone                   = "1"
  storage_mb             = 32768
  sku_name               = "B_Standard_B1ms"
  backup_retention_days  = 7

  tags = local.common_tags
}

resource "azurerm_postgresql_flexible_server_database" "vix" {
  name      = "vix_platform"
  server_id = azurerm_postgresql_flexible_server.vix.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

# ─── Redis Cache ──────────────────────────────────────────────
resource "azurerm_redis_cache" "vix" {
  name                = "redis-${var.project_name}-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.vix.location
  resource_group_name = azurerm_resource_group.vix.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  tags = local.common_tags
}

# ─── Storage Account ──────────────────────────────────────────
resource "azurerm_storage_account" "vix" {
  name                     = "st${var.project_name}${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.vix.name
  location                 = azurerm_resource_group.vix.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

  blob_properties {
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "POST", "PUT"]
      allowed_origins    = ["https://vixtech.co.ke"]
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "uploads" {
  name                  = "uploads"
  storage_account_name  = azurerm_storage_account.vix.name
  container_access_type = "private"
}

# ─── Application Insights ─────────────────────────────────────
resource "azurerm_application_insights" "vix" {
  name                = "appi-${var.project_name}-${var.environment}"
  location            = azurerm_resource_group.vix.location
  resource_group_name = azurerm_resource_group.vix.name
  application_type    = "Node.JS"

  tags = local.common_tags
}

# ─── Local values ─────────────────────────────────────────────
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Company     = "VIX Technologies"
    Owner       = "DevOps Team"
  }
}