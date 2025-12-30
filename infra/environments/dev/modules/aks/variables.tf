variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet for AKS"
  type        = string
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
}

variable "vm_size" {
  description = "VM size for nodes"
  type        = string
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling"
  type        = bool
}

variable "min_count" {
  description = "Minimum number of nodes"
  type        = number
}

variable "max_count" {
  description = "Maximum number of nodes"
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

variable "cost_center" {
  description = "Cost center identifier for resource tagging and cost tracking"
  type        = string
  default     = "engineering"
}

variable "scale_down_utilization_threshold" {
  description = "Node utilization threshold (0.0-1.0) below which a node can be considered for scale-down. Lower values = more aggressive cost savings"
  type        = number
  default     = 0.5
}
