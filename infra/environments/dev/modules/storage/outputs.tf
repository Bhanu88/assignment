output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.main.primary_blob_endpoint
}

output "private_endpoint_ip" {
  description = "Private IP address of the private endpoint"
  value       = azurerm_private_endpoint.blob.private_service_connection[0].private_ip_address
}

output "storage_container_name" {
  description = "Name of the storage container"
  value       = azurerm_storage_container.aks.name
}
