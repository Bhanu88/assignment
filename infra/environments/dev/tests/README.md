# AKS Deployment Verification Tests

This directory contains modular test scripts for verifying the AKS deployment.

## Scripts

### 1. `verify-csi-drivers.sh`
Verifies that all required CSI drivers are installed in the AKS cluster.

**Checks:**
- Azure Blob CSI driver
- Azure Disk CSI driver
- Azure File CSI driver

**Usage:**
```bash
./tests/verify-csi-drivers.sh
```

**Prerequisites:**
- `kubectl` configured with cluster access

### 2. `verify-private-endpoint.sh`
Verifies private endpoint configuration and DNS resolution.

**Checks:**
- Private endpoint exists for storage account
- DNS resolution from AKS cluster resolves to private IP
- Private endpoint connectivity

**Usage:**
```bash
./tests/verify-private-endpoint.sh <storage_account_name> <private_ip> [resource_group]
```

**Example:**
```bash
./tests/verify-private-endpoint.sh staksprivate1212 10.0.2.4 rg-aks-assignment
```

**Prerequisites:**
- Azure CLI authenticated
- `kubectl` configured with cluster access
- Terraform outputs available (or pass values explicitly)

### 3. `test-pvc-csi.sh`
Tests PersistentVolumeClaim (PVC) creation using Azure Blob CSI driver.

**Tests:**
- Creates PV with Azure Blob CSI driver
- Creates PVC and binds to PV
- Deploys test pod using the PVC
- Validates mount and accessibility

**Usage:**
```bash
./tests/test-pvc-csi.sh <storage_account_name> [container_name] [storage_account_key]
```

**Example:**
```bash
./tests/test-pvc-csi.sh staksprivate1212 aks-storage
```

**Prerequisites:**
- `kubectl` configured with cluster access
- Storage account and container already exist

**Cleanup:**
The script prompts for cleanup. To manually cleanup:
```bash
kubectl delete namespace csi-test
```

## Running All Tests

You can run all tests sequentially:

```bash
#!/bin/bash
set -e

# Get values from Terraform outputs
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
PRIVATE_IP=$(terraform output -raw private_endpoint_ip)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)

# Run verification tests
./tests/verify-csi-drivers.sh
./tests/verify-private-endpoint.sh $STORAGE_ACCOUNT $PRIVATE_IP $RESOURCE_GROUP
./tests/test-pvc-csi.sh $STORAGE_ACCOUNT

echo "✓ All tests completed successfully"
```

## Integration with GitHub Actions

These scripts are used in the GitHub Actions workflow:

```yaml
- name: Verify CSI Drivers
  run: chmod +x ./tests/verify-csi-drivers.sh && ./tests/verify-csi-drivers.sh

- name: Verify Private Endpoint
  run: |
    chmod +x ./tests/verify-private-endpoint.sh
    STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
    PRIVATE_IP=$(terraform output -raw private_endpoint_ip)
    ./tests/verify-private-endpoint.sh $STORAGE_ACCOUNT $PRIVATE_IP

- name: Test PVC with CSI Driver
  run: |
    chmod +x ./tests/test-pvc-csi.sh
    STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)
    ./tests/test-pvc-csi.sh $STORAGE_ACCOUNT
```

## Exit Codes

All scripts use standard exit codes:
- `0` - Success
- `1` - Failure

This allows them to be used in CI/CD pipelines with proper error handling.
