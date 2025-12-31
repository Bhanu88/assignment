# Azure AKS with CSI Storage - Terraform Solution

This repository contains a complete Terraform solution for deploying an Azure Kubernetes Service (AKS) cluster with Container Storage Interface (CSI) drivers, private endpoint connectivity to Azure Storage, and RBAC configuration following least privilege principles.

## Architecture Overview


The solution deploys the following Azure resources:

- **AKS Cluster** with CSI storage drivers enabled (blob, disk, file)
- **Virtual Network** with dedicated subnets for AKS and private endpoints
- **Storage Account** with private endpoint for secure connectivity
- **Private DNS Zone** for private endpoint resolution
- **RBAC** role assignments with least privilege access
- **Log Analytics** workspace for monitoring and diagnostics

## Project Structure

```
.
├── infra/
│   ├── README.md                              # Infrastructure documentation
│   └── environments/
│       └── dev/                               # Development environment
│           ├── main.tf                        # Main configuration file
│           ├── variables.tf                   # Variable definitions
│           ├── outputs.tf                     # Output definitions
│           ├── terraform.tfvars.example       # Example variables file
│           ├── backend.tfvars.example         # Backend configuration
│           ├── modules/
│           │   ├── aks/                       # AKS cluster module
│           │   │   ├── main.tf
│           │   │   ├── variables.tf
│           │   │   └── outputs.tf
│           │   ├── storage/                   # Storage account module
│           │   │   ├── main.tf
│           │   │   ├── variables.tf
│           │   │   └── outputs.tf
│           │   ├── networking/                # Networking module
│           │   │   ├── main.tf
│           │   │   ├── variables.tf
│           │   │   └── outputs.tf
│           │   └── rbac/                      # RBAC module
│           │       ├── main.tf
│           │       ├── variables.tf
│           │       └── outputs.tf
│           ├── tests/                         # Verification scripts
│           │   ├── verify-csi-drivers.sh      # CSI driver validation
│           │   ├── verify-private-endpoint.sh # Private endpoint testing
│           │   ├── test-pvc-csi.sh           # PVC creation testing
│           │   └── README.md                  # Testing documentation
│           └── examples/                      # Kubernetes manifest examples
│               ├── blob-storage-test.yaml    # Blob storage example
│               ├── disk-storage-test.yaml    # Disk storage example
│               ├── file-storage-test.yaml    # File storage example
│               └── README.md                  # Examples documentation
├── pipeline/
│   ├── README.md                              # Pipeline documentation
│   └── .github/                               # Reference/backup of workflows
│       ├── workflows/
│       │   └── terraform.yml                  # Workflow backup/reference
│       └── actions/
│           └── manage-storage-access/         # Action backup/reference
├── .github/                                   # Active GitHub Actions (at root)
│   ├── workflows/
│   │   └── terraform.yml                      # Active GitHub Actions workflow
│   └── actions/
│       └── manage-storage-access/             # Reusable composite action
│           ├── action.yml                     # Action definition
│           └── README.md                      # Action documentation
├── README.md                                   # Main project documentation
├── SOLUTION.md                                 # This file
├── AD-GROUP-SETUP.md                          # Azure AD RBAC setup guide
└── TCO.md                                      # Total cost of ownership
```

## Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Terraform** >= 1.5.0
3. **Azure CLI** installed and authenticated
4. **kubectl** for AKS cluster management
5. **Service Principal** or **Managed Identity** for Terraform authentication

# Create service principal with Contributor role at subscription scope
az ad sp create-for-rbac --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/<SUBSCRIPTION_ID>"
# Note the output values: appId, password, tenant
# Additionally, assign User Access Administrator role for RBAC assignments
az role assignment create `
  --assignee xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx `
  --role "User Access Administrator" `
  --scope "/subscriptions/<SUBSCRIPTION_ID>"

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd assignment
```

### 2. Configure Backend

Create `backend.tfvars` from the example:

```bash
cd infra/environments/dev
cp backend.tfvars.example backend.tfvars
```

# Set variables
RESOURCE_GROUP="tfstate-rg"
STORAGE_ACCOUNT="tfstatestorage$RANDOM"
CONTAINER="tfstate"
LOCATION="westeurope"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS \
  --encryption-services blob \
  --https-only true \
  --min-tls-version TLS1_2

# Create container
az storage container create \
  --name $CONTAINER \
  --account-name $STORAGE_ACCOUNT

# Enable versioning
az storage account blob-service-properties update \
  --account-name $STORAGE_ACCOUNT \
  --enable-versioning true

Edit `backend.tfvars` with your Azure Storage account details for Terraform state.

### 3. Configure Variables

Create `terraform.tfvars` from the example:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your desired configuration.

### 4. Initialize Terraform

```bash
terraform init -backend-config="backend.tfvars"
```

### 5. Validate Configuration

```bash
terraform validate
```

### 6. Plan Deployment

```bash
terraform plan -var-file="terraform.tfvars"
```

### 7. Apply Configuration

```bash
terraform apply -var-file="terraform.tfvars" -auto-approve
```

## Key Features

### CSI Storage Integration

The AKS cluster is configured with all CSI storage drivers enabled:

- **Blob CSI Driver**: For Azure Blob Storage
- **Disk CSI Driver**: For Azure Managed Disks
- **File CSI Driver**: For Azure Files
- **Snapshot Controller**: For volume snapshots

This is configured in the `infra/environments/dev/modules/aks/main.tf` file:

```hcl
storage_profile {
  blob_driver_enabled         = true
  disk_driver_enabled         = true
  file_driver_enabled         = true
  snapshot_controller_enabled = true
}
```

### Private Endpoint Connectivity

The storage account is configured with:

- **Public network access disabled** (after deployment)
- **Private endpoint** in a dedicated subnet
- **Private DNS zone** for name resolution
- **Network security group** protecting the private endpoint subnet

### Storage Security Automation

The deployment implements automated public access management:

**Deployment Flow:**
1. **Prepare Phase**: Public access temporarily enabled for Terraform operations
2. **Apply Phase**: Resources created/updated with Terraform
3. **Security Phase**: Public access automatically disabled
4. **Result**: Storage account accessible only via private endpoint

**Destroy Flow:**
1. **Pre-Destroy**: Public access temporarily re-enabled
2. **Destroy**: Resources cleaned up
3. **Result**: Clean removal without authorization errors

This is implemented using a reusable composite action in `.github/actions/manage-storage-access/`:

```yaml
# Enable public access
- uses: ./.github/actions/manage-storage-access
  with:
    action: enable

# Disable public access
- uses: ./.github/actions/manage-storage-access
  with:
    action: disable
```

See [.github/actions/manage-storage-access/README.md](.github/actions/manage-storage-access/README.md) for details.

### RBAC Configuration

Least privilege access is implemented through:

1. **Storage Blob Data Contributor** role for AKS kubelet identity to access storage
2. **Reader** role for AKS to read resource group metadata
3. **Custom role definition** demonstrating fine-grained permissions

### Security Features

- TLS 1.2 minimum for storage account
- HTTPS-only traffic enforcement
- Blob versioning and soft delete enabled
- Azure Policy enabled on AKS
- Container Insights for monitoring
- Network policies enabled

## CI/CD Integration

### GitHub Actions

The `.github/workflows/terraform.yml` file provides a comprehensive GitHub Actions workflow with automated security.

**Workflow Stages:**

1. **Validate**: Terraform format check and validation
2. **Prepare Storage**: Automatically enable public access if storage exists
3. **Plan**: Generate Terraform execution plan
4. **Apply**: Deploy infrastructure (with automatic security hardening)
5. **Verify**: Run comprehensive verification tests:
   - CSI driver validation
   - Private endpoint connectivity
   - PVC creation testing
6. **Destroy**: Clean infrastructure removal (with access re-enablement)

**Workflow Actions:**

You can trigger specific actions via workflow_dispatch:
- `all` - Run complete deployment pipeline
- `validate` - Only validation
- `plan` - Validate and plan
- `apply` - Full deployment
- `verify` - Only verification
- `destroy` - Clean destruction (skips validate/plan/apply)

**Setup Requirements:**

1. Add the following secrets to your GitHub repository:
   - `AZURE_CLIENT_ID`
   - `AZURE_CLIENT_SECRET`
   - `AZURE_SUBSCRIPTION_ID`
   - `AZURE_TENANT_ID`
   - `BACKEND_RESOURCE_GROUP`
   - `BACKEND_STORAGE_ACCOUNT`
   - `BACKEND_CONTAINER_NAME`

2. Create a production environment for manual approval

**Key Features:**

- **Conditional Execution**: Destroy action skips unnecessary validation/plan/apply steps
- **Security Automation**: Public access automatically managed during lifecycle
- **Modular Tests**: Uses scripts from `/tests` folder for verification
- **Reusable Components**: Composite action for storage access management

## Outputs

After successful deployment, the following outputs are available:

- `aks_cluster_name`: Name of the AKS cluster
- `aks_host`: Kubernetes API server endpoint
- `storage_account_name`: Name of the storage account
- `private_endpoint_ip`: Private IP of the storage endpoint
- `vnet_id`: Virtual network ID

View outputs:

```bash
terraform output
```

Get kubeconfig:

```bash
terraform output -raw aks_kube_config > ~/.kube/config
```

## Post-Deployment Verification

### Automated Testing

The repository includes comprehensive test scripts in the `infra/environments/dev/tests/` folder:

```bash
# Navigate to dev environment
cd infra/environments/dev

# 1. Verify CSI Drivers
./tests/verify-csi-drivers.sh

# 2. Verify Private Endpoint
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
PRIVATE_IP=$(terraform output -raw private_endpoint_ip)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
./tests/verify-private-endpoint.sh $STORAGE_ACCOUNT $PRIVATE_IP $RESOURCE_GROUP

# 3. Test PVC with CSI Driver
./tests/test-pvc-csi.sh $STORAGE_ACCOUNT
```

See [infra/environments/dev/tests/README.md](infra/environments/dev/tests/README.md) for detailed documentation on each test script.

### Manual Verification

### Connect to AKS

```bash
az aks get-credentials --resource-group rg-aks-assignment --name aks-cluster
```

### Verify CSI Drivers

```bash
kubectl get csidrivers
```

Expected output:
```
NAME                  ATTACHREQUIRED  PODINFOONMOUNT  MODES
blob.csi.azure.com    true            true            Persistent,Ephemeral
disk.csi.azure.com    true            true            Persistent
file.csi.azure.com    true            true            Persistent,Ephemeral
```

### Verify Nodes

```bash
kubectl get nodes
```

### Verify Storage Account Security

```bash
# Check that public access is disabled
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)

az storage account show \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --query "{Name:name, PublicAccess:publicNetworkAccess, DefaultAction:networkRuleSet.defaultAction}" \
  --output table
```

Expected output:
```
Name                  PublicAccess  DefaultAction
--------------------  ------------  -------------
staksprivate1212      Disabled      Deny
```


#### 1. Test Azure Disk CSI Driver

```bash
# Create test namespace
kubectl create namespace storage-test

# Create StorageClass for Azure Disk
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: managed-csi-premium
provisioner: disk.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF

# Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-disk-pvc
  namespace: storage-test
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: managed-csi-premium
  resources:
    requests:
      storage: 5Gi
EOF

# Create test pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: disk-test-pod
  namespace: storage-test
spec:
  containers:
  - name: test
    image: mcr.microsoft.com/azure-cli
    command: ["/bin/sh"]
    args: ["-c", "echo 'Testing disk storage' > /mnt/data/test.txt && cat /mnt/data/test.txt && sleep 3600"]
    volumeMounts:
    - name: disk-volume
      mountPath: /mnt/data
  volumes:
  - name: disk-volume
    persistentVolumeClaim:
      claimName: azure-disk-pvc
EOF

# Verify disk storage
kubectl wait --for=condition=ready pod/disk-test-pod -n storage-test --timeout=300s
kubectl logs disk-test-pod -n storage-test
kubectl exec -it disk-test-pod -n storage-test -- ls -la /mnt/data
```

#### 2. Test Azure Files CSI Driver

```bash
# Create StorageClass for Azure Files
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azurefile-csi-premium
provisioner: file.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true
mountOptions:
  - dir_mode=0777
  - file_mode=0777
  - uid=0
  - gid=0
  - mfsymlinks
  - cache=strict
  - actimeo=30
EOF

# Create PVC
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-file-pvc
  namespace: storage-test
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-csi-premium
  resources:
    requests:
      storage: 100Gi
EOF

# Create test pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: file-test-pod
  namespace: storage-test
spec:
  containers:
  - name: test
    image: mcr.microsoft.com/azure-cli
    command: ["/bin/sh"]
    args: ["-c", "echo 'Testing file storage' > /mnt/files/test.txt && cat /mnt/files/test.txt && sleep 3600"]
    volumeMounts:
    - name: file-volume
      mountPath: /mnt/files
  volumes:
  - name: file-volume
    persistentVolumeClaim:
      claimName: azure-file-pvc
EOF

# Verify file storage
kubectl wait --for=condition=ready pod/file-test-pod -n storage-test --timeout=300s
kubectl logs file-test-pod -n storage-test
kubectl exec -it file-test-pod -n storage-test -- ls -la /mnt/files
```

#### 3. Test Azure Blob CSI Driver

```bash
# Get storage account details
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
RESOURCE_GROUP="rg-aks-assignment"

# Get storage account key
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT --query '[0].value' -o tsv)

# Create secret for blob storage
kubectl create secret generic azure-blob-secret \
  --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT \
  --from-literal=azurestorageaccountkey=$STORAGE_KEY \
  --namespace=storage-test

# Create StorageClass for blob
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: azureblob-fuse-premium
provisioner: blob.csi.azure.com
parameters:
  skuName: Premium_LRS
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
  - -o allow_other
  - --file-cache-timeout-in-seconds=120
EOF

# Create PVC for blob
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: azure-blob-pvc
  namespace: storage-test
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azureblob-fuse-premium
  resources:
    requests:
      storage: 10Gi
EOF

# Create test pod
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: blob-test-pod
  namespace: storage-test
spec:
  containers:
  - name: test
    image: mcr.microsoft.com/azure-cli
    command: ["/bin/sh"]
    args: ["-c", "echo 'Testing blob storage' > /mnt/blob/test.txt && ls -la /mnt/blob && sleep 3600"]
    volumeMounts:
    - name: blob-volume
      mountPath: /mnt/blob
  volumes:
  - name: blob-volume
    persistentVolumeClaim:
      claimName: azure-blob-pvc
EOF

# Verify blob storage
kubectl wait --for=condition=ready pod/blob-test-pod -n storage-test --timeout=300s
kubectl logs blob-test-pod -n storage-test
```

#### 4. Test Private Endpoint Connectivity

```bash
# Deploy a test pod with network tools
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: network-test-pod
  namespace: default
spec:
  containers:
  - name: network-tools
    image: mcr.microsoft.com/azure-cli
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
EOF

# Wait for pod to be ready
kubectl wait --for=condition=ready pod/network-test-pod --timeout=120s

# Test DNS resolution (should resolve to private IP)
kubectl exec network-test-pod -- nslookup ${STORAGE_ACCOUNT}.blob.core.windows.net

# Test HTTPS connectivity
kubectl exec network-test-pod -- curl -I https://${STORAGE_ACCOUNT}.blob.core.windows.net

# Comprehensive network test
kubectl exec network-test-pod -- bash -c "
  echo '=== DNS Resolution ==='
  nslookup ${STORAGE_ACCOUNT}.blob.core.windows.net
  
  echo -e '\n=== Private Endpoint IP ==='
  getent hosts ${STORAGE_ACCOUNT}.blob.core.windows.net
  
  echo -e '\n=== HTTPS Connection Test ==='
  curl -v -m 10 https://${STORAGE_ACCOUNT}.blob.core.windows.net 2>&1 | grep -E 'Connected to|SSL connection'
"
```

#### 5. Verify Private Endpoint Configuration

```bash
# Check private endpoint status
az network private-endpoint list --resource-group $RESOURCE_GROUP -o table

# Get private IP address
az network private-endpoint show \
  --name "pe-${STORAGE_ACCOUNT}" \
  --resource-group $RESOURCE_GROUP \
  --query 'customDnsConfigs[0].ipAddresses[0]' -o tsv

# Verify private DNS zone link
az network private-dns link vnet list \
  --resource-group $RESOURCE_GROUP \
  --zone-name privatelink.blob.core.windows.net -o table

# Verify private endpoint connection
az network private-endpoint show \
  --name "pe-${STORAGE_ACCOUNT}" \
  --resource-group $RESOURCE_GROUP \
  --query '{name:name, provisioningState:provisioningState, privateLinkServiceConnections:privateLinkServiceConnections[0].privateLinkServiceConnectionState}' -o json
```

#### 6. Verify All Storage Tests

```bash
# Check PVC status
kubectl get pvc -n storage-test

# Check pod status
kubectl get pods -n storage-test

# View all storage test logs
kubectl logs disk-test-pod -n storage-test
kubectl logs blob-test-pod -n storage-test
kubectl logs file-test-pod -n storage-test

# Describe PVCs to see binding details
kubectl describe pvc azure-disk-pvc -n storage-test
kubectl describe pvc azure-file-pvc -n storage-test
kubectl describe pvc azure-blob-pvc -n storage-test
```

#### 7. Expected Results

**Success Indicators:**
-  DNS resolves to private IP (10.x.x.x range)
- HTTPS connection succeeds from AKS pods
- All PVCs are in "Bound" status
- Test pods are "Running" and logs show successful file operations
- Blob operations work from within the cluster
- Connection fails from outside the VNet

**Failure Indicators:**
- DNS resolves to public IP
- Connection timeouts from AKS pods
- "Public network access is disabled" errors
- PVCs stuck in "Pending" status

#### 8. Cleanup Test Resources

```bash
# Delete test namespace (removes all test resources)
kubectl delete namespace storage-test

# Delete network test pod
kubectl delete pod network-test-pod --ignore-not-found
```

## Troubleshooting

### Common Issues

1. **Storage account name already exists**: Change `storage_account_name` in `terraform.tfvars` to a unique value

2. **Backend initialization fails**: Verify backend storage account exists and you have access

3. **AKS deployment timeout**: Check Azure subscription quotas for VMs

4. **Private endpoint resolution fails**: Verify private DNS zone is linked to the VNet

### Debug Commands

```bash
# Check Terraform state
terraform show

# View detailed logs
TF_LOG=DEBUG terraform apply

# Validate AKS configuration
az aks show --resource-group rg-aks-assignment --name aks-cluster
```

## State Management

Terraform state is stored remotely in Azure Storage for:

- **Team collaboration**
- **State locking** (prevents concurrent modifications)
- **Secure storage** with encryption at rest
- **State versioning** and backup

## Cleanup

To destroy all resources:

```bash
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

## Best Practices Implemented

1. **Modularity**: Resources organized into reusable modules
2. **Variables**: All configurable values externalized
3. **Outputs**: Important values exposed for integration
4. **Remote State**: Centralized state management
5. **Security**: 
   - Least privilege RBAC
   - Private networking with automated public access management
   - Zero trust architecture (private endpoints only)
6. **Monitoring**: Log Analytics and Container Insights
7. **Documentation**: Comprehensive documentation with testing guides
8. **CI/CD**: 
   - Automated validation and deployment pipelines
   - Reusable composite actions
   - Conditional workflow execution
9. **Testing**: 
   - Modular test scripts
   - Automated verification
   - Independent test execution
10. **Automation**: Security controls automated throughout deployment lifecycle

## Repository Structure Highlights

### Reusable Components

- **`.github/actions/manage-storage-access/`**: Composite action for storage access management
- **`tests/`**: Independent verification scripts
- **`modules/`**: Terraform modules by resource type
- **`examples/`**: Kubernetes manifest examples

### Documentation

- **[README.md](README.md)**: Quick start and overview
- **[SOLUTION.md](SOLUTION.md)**: This file - comprehensive solution documentation
- **[AD-GROUP-SETUP.md](AD-GROUP-SETUP.md)**: Azure AD RBAC setup guide
- **[tests/README.md](tests/README.md)**: Testing scripts documentation
- **[examples/README.md](examples/README.md)**: Kubernetes examples guide
- **[.github/actions/manage-storage-access/README.md](.github/actions/manage-storage-access/README.md)**: Action usage guide



## License

This project is for demonstration purposes.
