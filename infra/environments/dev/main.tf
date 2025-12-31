terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
  }

  backend "azurerm" {
    # Backend configuration should be provided via backend config file or CLI
    # Example: terraform init -backend-config="backend.tfvars"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Networking Module
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_name           = var.vnet_name
  vnet_address_space  = var.vnet_address_space
  aks_subnet_prefix   = var.aks_subnet_prefix
  pe_subnet_prefix    = var.pe_subnet_prefix
  tags                = var.tags
}

# AKS Module
module "aks" {
  source = "./modules/aks"

  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  cluster_name                     = var.aks_cluster_name
  dns_prefix                       = var.aks_dns_prefix
  kubernetes_version               = var.kubernetes_version
  subnet_id                        = module.networking.aks_subnet_id
  node_count                       = var.node_count
  vm_size                          = var.vm_size
  enable_auto_scaling              = var.enable_auto_scaling
  min_count                        = var.min_count
  max_count                        = var.max_count
  cost_center                      = var.cost_center
  scale_down_utilization_threshold = var.scale_down_utilization_threshold
  tags                             = var.tags
}

# Storage Account Module
module "storage" {
  source = "./modules/storage"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = azurerm_resource_group.main.location
  storage_account_name       = var.storage_account_name
  account_tier               = var.storage_account_tier
  account_replication_type   = var.storage_replication_type
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  private_dns_zone_id        = module.networking.private_dns_zone_id
  tags                       = var.tags
}

# RBAC Module
module "rbac" {
  source = "./modules/rbac"

  skip_rbac_assignments          = var.skip_rbac_assignments
  aks_principal_id               = module.aks.kubelet_identity_object_id
  storage_account_id             = module.storage.storage_account_id
  resource_group_id              = azurerm_resource_group.main.id
  aks_cluster_id                 = module.aks.cluster_id
  aks_user_group_object_id       = var.aks_user_group_object_id
  aks_power_user_group_object_id = var.aks_power_user_group_object_id
  aks_admin_group_object_id      = var.aks_admin_group_object_id
}
