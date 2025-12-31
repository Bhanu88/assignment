output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "Kubeconfig for the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "host" {
  description = "AKS cluster API server endpoint"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet identity"
  value       = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
}

output "principal_id" {
  description = "Principal ID of the AKS cluster managed identity"
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}
