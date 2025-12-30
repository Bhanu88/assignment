# Azure AD Group Setup for AKS RBAC

This guide explains how to set up Azure AD groups for AKS access control with separate user and admin groups.

## Overview

The Terraform configuration now includes Azure AD integration with three group-based access levels:

1. **Users Group**: Read-only access to all AKS resources
2. **Power Users Group**: Can deploy, restart, and manage resources (no delete/RBAC changes)
3. **Admins Group**: Full administrative access to AKS cluster

## Step 1: Create Azure AD Groups

### Create Users Group

```bash
# Create AD group for AKS users
az ad group create \
  --display-name "AKS-Users" \
  --mail-nickname "aks-users" \
  --description "Users with read access to AKS cluster"

# Get the Object ID
USER_GROUP_ID=$(az ad group show --group "AKS-Users" --query id -o tsv)
echo "User Group Object ID: $USER_GROUP_ID"
```

### Create Power Users Group

```bash
# Create AD group for AKS power users
az ad group create \
  --display-name "AKS-PowerUsers" \
  --mail-nickname "aks-powerusers" \
  --description "Power users who can deploy and restart resources in AKS cluster"

# Get the Object ID
POWER_USER_GROUP_ID=$(az ad group show --group "AKS-PowerUsers" --query id -o tsv)
echo "Power User Group Object ID: $POWER_USER_GROUP_ID"
```

### Create Admins Group

```bash
# Create AD group for AKS admins
az ad group create \
  --display-name "AKS-Admins" \
  --mail-nickname "aks-admins" \
  --description "Administrators with full access to AKS cluster"

# Get the Object ID
ADMIN_GROUP_ID=$(az ad group show --group "AKS-Admins" --query id -o tsv)
echo "Admin Group Object ID: $ADMIN_GROUP_ID"
```

## Step 2: Add Members to Groups

### Add Users to Users Group

```bash
# Add a user to the users group
az ad group member add \
  --group "AKS-Users" \
  --member-id <USER_OBJECT_ID>

# Or by user principal name
az ad group member add \
  --group "AKS-Users" \
  --member-id $(az ad user show --id user@domain.com --query id -o tsv)
```

### Add Users to Power Users Group

```bash
# Add a user to the power users group
az ad group member add \
  --group "AKS-PowerUsers" \
  --member-id <USER_OBJECT_ID>

# Or by user principal name
az ad group member add \
  --group "AKS-PowerUsers" \
  --member-id $(az ad user show --id poweruser@domain.com --query id -o tsv)
```

### Add Users to Admins Group

```bash
# Add a user to the admins group
az ad group member add \
  --group "AKS-Admins" \
  --member-id <USER_OBJECT_ID>

# Or by user principal name
az ad group member add \
  --group "AKS-Admins" \
  --member-id $(az ad user show --id admin@domain.com --query id -o tsv)
```

## Step 3: Update terraform.tfvars

Add the Object IDs to your `terraform.tfvars` file:

```hcl
# Azure AD Group Object IDs for AKS RBAC
aks_user_group_object_id       = "00000000-0000-0000-0000-000000000000"  # Replace with Users Group Object ID
aks_power_user_group_object_id = "00000000-0000-0000-0000-000000000000"  # Replace with Power Users Group Object ID
aks_admin_group_object_id      = "00000000-0000-0000-0000-000000000000"  # Replace with Admins Group Object ID
```

## Step 4: Apply Terraform Configuration

```bash
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars" -auto-approve
```

## Assigned Roles

### Users Group Permissions

The **AKS-Users** group receives the following roles:

1. **Azure Kubernetes Service Cluster User Role**
   - Allows getting cluster user credentials
   - Required to connect to the cluster

2. **Azure Kubernetes Service RBAC Reader**
   - Cluster-wide read-only access to ALL Kubernetes objects
   - Can view pods, services, deployments, configmaps, secrets (metadata only), etc.
   - Can list resources across all namespaces
   - Cannot create, modify, or delete resources

### Power Users Group Permissions

The **AKS-PowerUsers** group receives the following roles:

1. **Azure Kubernetes Service Cluster User Role**
   - Allows getting cluster user credentials
   - Required to connect to the cluster

2. **Azure Kubernetes Service RBAC Writer**
   - Can create, update, and restart most Kubernetes resources
   - Can deploy applications (deployments, pods, services)
   - Can restart pods and deployments
   - Can create and modify ConfigMaps and Secrets
   - Can scale deployments
   - **Cannot** delete cluster-level resources
   - **Cannot** modify RBAC permissions
   - **Cannot** delete namespaces

### Admins Group Permissions

The **AKS-Admins** group receives the following roles:

1. **Azure Kubernetes Service Cluster Admin Role**
   - Allows getting cluster admin credentials
   - Full access to cluster management

2. **Azure Kubernetes Service RBAC Cluster Admin**
   - Full administrative access to all Kubernetes resources
   - Can create, modify, and delete all resources
   - Cluster-wide permissions

## Step 5: Connect to AKS with AD Authentication

### For Users (Read Access)

```bash
# Get user credentials (requires Azure login)
az aks get-credentials \
  --resource-group rg-aks-assignment \
  --name aks-cluster \
  --overwrite-existing

# Test read access - should work
kubectl get pods --all-namespaces
kubectl get deployments --all-namespaces
kubectl get services --all-namespaces

# Test write access - should fail
kubectl run nginx --image=nginx
```

### For Power Users (Deploy and Restart)

```bash
# Get credentials
az aks get-credentials \
  --resource-group rg-aks-assignment \
  --name aks-cluster \
  --overwrite-existing

# Test deployment - should work
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3

# Test restart - should work
kubectl rollout restart deployment nginx

# Test service creation - should work
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Clean up
kubectl delete deployment nginx
kubectl delete service nginx
```

### For Admins (Full Access)

```bash
# Get admin credentials
az aks get-credentials \
  --resource-group rg-aks-assignment \
  --name aks-cluster \
  --admin \
  --overwrite-existing

# Or use Azure AD authentication
az aks get-credentials \
  --resource-group rg-aks-assignment \
  --name aks-cluster \
  --overwrite-existing

# Test full access - should work
kubectl run nginx --image=nginx
kubectl delete pod nginx
```

## Verify Group Membership

### List Members of a Group

```bash
# List users in the users group
az ad group member list --group "AKS-Users" --query "[].{Name:displayName, Email:userPrincipalName}" -o table

# List users in the power users group
az ad group member list --group "AKS-PowerUsers" --query "[].{Name:displayName, Email:userPrincipalName}" -o table

# List users in the admins group
az ad group member list --group "AKS-Admins" --query "[].{Name:displayName, Email:userPrincipalName}" -o table
```

### Check User's Group Membership

```bash
# Check which groups a user belongs to
az ad user get-member-groups \
  --id user@domain.com \
  --query "[].displayName" -o table
```

## Verify Role Assignments

```bash
# List all role assignments for the AKS cluster
az role assignment list \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/rg-aks-assignment/providers/Microsoft.ContainerService/managedClusters/aks-cluster" \
  --query "[].{Principal:principalName, Role:roleDefinitionName}" -o table
```

## Troubleshooting

### Issue: User Cannot Access Cluster

**Check:**
1. User is member of appropriate AD group
2. User has run `az login` with correct account
3. User has run `az aks get-credentials` to download kubeconfig
4. Azure RBAC is enabled on the cluster

```bash
# Verify Azure RBAC is enabled
az aks show \
  --resource-group rg-aks-assignment \
  --name aks-cluster \
  --query "aadProfile.enableAzureRbac" -o tsv
```

### Issue: Permission Denied Errors

**Solution:**
```bash
# Clear cached credentials
az account clear
az login

# Re-download kubeconfig
az aks get-credentials \
  --resource-group rg-aks-assignment \
  --name aks-cluster \
  --overwrite-existing

# Test authentication
kubectl auth whoami
```

### Issue: Role Assignments Not Working

**Check:**
```bash
# Verify role assignments exist
az role assignment list \
  --assignee <GROUP_OBJECT_ID> \
  --all

# Propagation can take 5-10 minutes
# Wait and retry
```

## Additional Kubernetes RBAC (Optional)

For finer-grained namespace-level permissions, you can create Kubernetes RoleBindings:

```yaml
# users-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: aks-users-view
  namespace: default
subjects:
- kind: Group
  name: <USER_GROUP_OBJECT_ID>
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
```

Apply with:
```bash
kubectl apply -f users-rolebinding.yaml
```

## Security Best Practices

1. **Principle of Least Privilege**: Only grant necessary permissions
2. **Regular Audits**: Review group memberships regularly
3. **Conditional Access**: Consider implementing Azure AD Conditional Access policies
4. **MFA**: Require multi-factor authentication for admin access
5. **Audit Logs**: Monitor Azure AD and AKS audit logs for suspicious activity

## References

- [AKS Azure AD Integration](https://learn.microsoft.com/en-us/azure/aks/managed-aad)
- [Azure RBAC for Kubernetes](https://learn.microsoft.com/en-us/azure/aks/manage-azure-rbac)
- [Built-in Kubernetes Roles](https://learn.microsoft.com/en-us/azure/aks/concepts-identity#kubernetes-rbac)
