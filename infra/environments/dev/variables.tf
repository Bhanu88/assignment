variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-assignment"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Project     = "AKS-Assignment"
  }
}

# Networking Variables
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "vnet-aks"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "aks_subnet_prefix" {
  description = "Address prefix for AKS subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "pe_subnet_prefix" {
  description = "Address prefix for Private Endpoint subnet"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

# AKS Variables
variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "aks-cluster"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for AKS cluster"
  type        = string
  default     = "akscluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_count" {
  description = "Initial number of nodes in the default node pool"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the node pool"
  type        = bool
  default     = true
}

variable "min_count" {
  description = "Minimum number of nodes for auto-scaling"
  type        = number
  default     = 2
}

variable "max_count" {
  description = "Maximum number of nodes for auto-scaling"
  type        = number
  default     = 5
}

# Storage Variables
variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "staksprivate"
}

variable "storage_account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

# Azure AD Group Variables
variable "skip_rbac_assignments" {
  description = "Skip creating RBAC role assignments (set to true if service principal lacks User Access Administrator permissions)"
  type        = bool
  default     = false
}

variable "aks_user_group_object_id" {
  description = "Object ID of the Azure AD group for AKS users (read-only access to all resources)"
  type        = string
  default     = ""
}

variable "aks_power_user_group_object_id" {
  description = "Object ID of the Azure AD group for AKS power users (can deploy and restart resources)"
  type        = string
  default     = ""
}

variable "aks_admin_group_object_id" {
  description = "Object ID of the Azure AD group for AKS administrators (full access)"
  type        = string
  default     = ""
}

# Cost Optimization Variables
variable "cost_center" {
  description = "Cost center identifier for resource tagging and cost tracking"
  type        = string
  default     = "engineering"
}

variable "scale_down_utilization_threshold" {
  description = "Node utilization threshold (0.0-1.0) below which nodes can be scaled down. Lower = more aggressive cost savings (recommended: 0.5 for dev, 0.7 for prod)"
  type        = number
  default     = 0.5
}
