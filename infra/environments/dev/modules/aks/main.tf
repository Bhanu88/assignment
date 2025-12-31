resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "default"
    node_count          = var.enable_auto_scaling ? null : var.node_count
    vm_size             = var.vm_size
    vnet_subnet_id      = var.subnet_id
    enable_auto_scaling = var.enable_auto_scaling
    min_count           = var.enable_auto_scaling ? var.min_count : null
    max_count           = var.enable_auto_scaling ? var.max_count : null
    os_disk_size_gb     = 30
    type                = "VirtualMachineScaleSets"

    # Node labels for cost optimization
    node_labels = {
      "cost-center"   = var.cost_center
      "workload-type" = "general"
      "auto-scaling"  = var.enable_auto_scaling ? "enabled" : "disabled"
    }

    upgrade_settings {
      max_surge = "10%"
    }
  }

  # Cluster autoscaler configuration for cost optimization
  auto_scaler_profile {
    # Balance similar node groups to optimize costs
    balance_similar_node_groups = true

    # Expander strategy - priority gives control over node pool selection
    expander = "priority"

    # Maximum time for empty nodes before scale-down (reduced for cost savings)
    max_graceful_termination_sec = 600

    # Maximum total unready percentage before stopping operations
    max_node_provisioning_time = "15m"
    max_unready_percentage     = 45

    # Unready node time before considering for removal
    new_pod_scale_up_delay = "10s"

    # Scale down configuration for aggressive cost optimization
    scale_down_delay_after_add       = "10m" # Wait 10 min after scale-up before scale-down
    scale_down_delay_after_delete    = "10s" # Quick evaluation after node deletion
    scale_down_delay_after_failure   = "3m"  # Brief pause after failed scale-down
    scale_down_unneeded              = "10m" # Scale down unneeded nodes after 10 min
    scale_down_unready               = "20m" # Remove unready nodes after 20 min
    scale_down_utilization_threshold = var.scale_down_utilization_threshold

    # Don't remove nodes that are running important system pods
    skip_nodes_with_local_storage = false
    skip_nodes_with_system_pods   = true
  }

  identity {
    type = "SystemAssigned"
  }

  # Enable Azure AD integration with Azure RBAC
  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  # OIDC issuer is required for Azure AD RBAC and Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Enable CSI drivers for storage
  storage_profile {
    blob_driver_enabled         = true
    disk_driver_enabled         = true
    file_driver_enabled         = true
    snapshot_controller_enabled = true
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.1.0.0/16"
    dns_service_ip    = "10.1.0.10"
  }

  # Security and monitoring features
  azure_policy_enabled = true

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  }

  tags = var.tags
}

# Log Analytics Workspace for AKS monitoring
resource "azurerm_log_analytics_workspace" "main" {
  name                = "${var.cluster_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Enable Container Insights
resource "azurerm_log_analytics_solution" "main" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }

  tags = var.tags
}
