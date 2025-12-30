variable "skip_rbac_assignments" {
  description = "Skip creating RBAC role assignments"
  type        = bool
  default     = false
}

variable "aks_principal_id" {
  description = "Principal ID of the AKS kubelet identity"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account"
  type        = string
}

variable "resource_group_id" {
  description = "ID of the resource group"
  type        = string
}

variable "aks_cluster_id" {
  description = "ID of the AKS cluster"
  type        = string
}

variable "aks_user_group_object_id" {
  description = "Object ID of the Azure AD group for AKS users (read access)"
  type        = string
  default     = ""
}

variable "aks_power_user_group_object_id" {
  description = "Object ID of the Azure AD group for AKS power users (deploy and restart resources)"
  type        = string
  default     = ""
}

variable "aks_admin_group_object_id" {
  description = "Object ID of the Azure AD group for AKS administrators"
  type        = string
  default     = ""
}
