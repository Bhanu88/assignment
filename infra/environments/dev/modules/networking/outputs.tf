output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.aks.id
}

output "pe_subnet_id" {
  description = "ID of the private endpoint subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "private_dns_zone_id" {
  description = "ID of the private DNS zone for blob storage"
  value       = azurerm_private_dns_zone.blob.id
}

output "private_dns_zone_name" {
  description = "Name of the private DNS zone"
  value       = azurerm_private_dns_zone.blob.name
}
