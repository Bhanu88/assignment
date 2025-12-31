# Example terraform.tfvars file
# Copy this to terraform.tfvars and customize values

resource_group_name  = "rg-aks-assignment"
location             = "westeurope"
aks_cluster_name     = "aks-cluster"
storage_account_name = "staksprivate1212" # Must be globally unique, 3-24 lowercase alphanumeric characters
#az aks get-versions --location "westeurope" --output table to see available versions in certain region
kubernetes_version    = "1.34.0"
node_count            = 2
vm_size               = "Standard_D2s_v3"
skip_rbac_assignments = false

tags = {
  Environment = "Development"
  ManagedBy   = "Terraform"
  Project     = "AKS-Assignment"
}

aks_user_group_object_id       = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Replace with your Azure AD group object ID
aks_power_user_group_object_id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Replace with your Azure AD group object ID
aks_admin_group_object_id      = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" # Replace with your Azure AD group object ID
