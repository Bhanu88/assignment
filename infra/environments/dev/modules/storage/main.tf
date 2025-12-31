resource "azurerm_storage_account" "main" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Security settings
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  public_network_access_enabled   = true # Temporarily enabled for deployment - disabled via post-deployment automation
  allow_nested_items_to_be_public = false

  # Advanced threat protection
  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 7
    }

    container_delete_retention_policy {
      days = 7
    }
  }

  network_rules {
    default_action             = "Allow" # Temporarily allowed for deployment - set to Deny via post-deployment automation
    bypass                     = ["AzureServices"]
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  tags = var.tags
}

# Private Endpoint for Blob Storage
resource "azurerm_private_endpoint" "blob" {
  name                = "${var.storage_account_name}-pe-blob"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-psc-blob"
    private_connection_resource_id = azurerm_storage_account.main.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }

  tags = var.tags
}

# Optional: Storage Container for AKS
resource "azurerm_storage_container" "aks" {
  name                  = "aks-storage"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}
