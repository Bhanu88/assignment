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

aks_user_group_object_id       = "fefcb269-42c9-4be7-a6ce-27ebff8c5c7e" # Replace with your Azure AD group object ID
aks_power_user_group_object_id = "29e6cec8-2219-4303-9902-e2cb44d2212f" # Replace with your Azure AD group object ID
aks_admin_group_object_id      = "c71344d4-ae5d-4ff1-b3a2-e64cb8afd6b7" # Replace with your Azure AD group object ID