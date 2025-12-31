variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
}

variable "account_replication_type" {
  description = "Storage replication type"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "ID of the subnet for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "ID of the private DNS zone"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
