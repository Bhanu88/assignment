# Role assignment for AKS to access Storage Account
# Grant "Storage Blob Data Contributor" role to AKS kubelet identity
# NOTE: Requires User Access Administrator or Owner role on the subscription
resource "azurerm_role_assignment" "aks_storage_blob_contributor" {
  count                = var.skip_rbac_assignments ? 0 : 1
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.aks_principal_id
}

# Grant "Reader" role to AKS on the resource group
# This allows AKS to read metadata about the resource group
resource "azurerm_role_assignment" "aks_rg_reader" {
  count                = var.skip_rbac_assignments ? 0 : 1
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = var.aks_principal_id
}

# Note: Custom role definition removed due to permission requirements
# Creating custom role definitions requires Owner or User Access Administrator role
# The built-in "Storage Blob Data Contributor" role above provides sufficient permissions

# Azure AD Group RBAC for AKS Users (Read Access)
# Grant "Azure Kubernetes Service Cluster User Role" to users group
resource "azurerm_role_assignment" "aks_user_group" {
  count                = !var.skip_rbac_assignments && var.aks_user_group_object_id != "" ? 1 : 0
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.aks_user_group_object_id
}

# Grant "Azure Kubernetes Service RBAC Reader" for cluster-wide read access to all resources
resource "azurerm_role_assignment" "aks_user_group_rbac_reader" {
  count                = !var.skip_rbac_assignments && var.aks_user_group_object_id != "" ? 1 : 0
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service RBAC Reader"
  principal_id         = var.aks_user_group_object_id
}

# Azure AD Group RBAC for AKS Power Users (Deploy and Restart)
# Grant "Azure Kubernetes Service Cluster User Role" to power users group
resource "azurerm_role_assignment" "aks_power_user_group" {
  count                = !var.skip_rbac_assignments && var.aks_power_user_group_object_id != "" ? 1 : 0
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = var.aks_power_user_group_object_id
}

# Grant "Azure Kubernetes Service RBAC Writer" for deploy and restart capabilities
resource "azurerm_role_assignment" "aks_power_user_group_rbac_writer" {
  count                = !var.skip_rbac_assignments && var.aks_power_user_group_object_id != "" ? 1 : 0
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service RBAC Writer"
  principal_id         = var.aks_power_user_group_object_id
}

# Azure AD Group RBAC for AKS Admins (Full Access)
# Grant "Azure Kubernetes Service Cluster Admin Role" to admins group
resource "azurerm_role_assignment" "aks_admin_group" {
  count                = !var.skip_rbac_assignments && var.aks_admin_group_object_id != "" ? 1 : 0
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role"
  principal_id         = var.aks_admin_group_object_id
}

# Grant "Azure Kubernetes Service RBAC Cluster Admin" to admin group
resource "azurerm_role_assignment" "aks_admin_group_rbac_admin" {
  count                = !var.skip_rbac_assignments && var.aks_admin_group_object_id != "" ? 1 : 0
  scope                = var.aks_cluster_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = var.aks_admin_group_object_id
}
