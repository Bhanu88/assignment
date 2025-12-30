output "aks_storage_role_assignment_id" {
  description = "ID of the role assignment for AKS to storage"
  value       = var.skip_rbac_assignments ? null : azurerm_role_assignment.aks_storage_blob_contributor[0].id
}

output "aks_rg_reader_role_assignment_id" {
  description = "ID of the role assignment for AKS to resource group"
  value       = var.skip_rbac_assignments ? null : azurerm_role_assignment.aks_rg_reader[0].id
}
