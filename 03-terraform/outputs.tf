# VIX Technologies — Terraform Outputs

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.vix.name
}

output "app_service_url" {
  description = "VIX Platform URL"
  value       = "https://${azurerm_linux_web_app.vix_platform.default_hostname}"
}

output "container_registry_url" {
  description = "Container registry login server"
  value       = azurerm_container_registry.vix.login_server
}

output "database_host" {
  description = "PostgreSQL server hostname"
  value       = azurerm_postgresql_flexible_server.vix.fqdn
  sensitive   = true
}

output "redis_hostname" {
  description = "Redis cache hostname"
  value       = azurerm_redis_cache.vix.hostname
  sensitive   = true
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.vix.name
}

output "application_insights_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.vix.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.vix.connection_string
  sensitive   = true
}