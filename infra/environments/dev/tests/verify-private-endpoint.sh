#!/bin/bash
set -e

# Arguments
STORAGE_ACCOUNT=$1
PRIVATE_IP=$2
RESOURCE_GROUP=${3:-"rg-aks-assignment"}

if [ -z "$STORAGE_ACCOUNT" ] || [ -z "$PRIVATE_IP" ]; then
  echo "Usage: $0 <storage_account_name> <private_ip> [resource_group]"
  exit 1
fi

echo "============================================"
echo "Verifying Private Endpoint Configuration"
echo "============================================"

echo "Storage Account: $STORAGE_ACCOUNT"
echo "Expected Private IP: $PRIVATE_IP"
echo "Resource Group: $RESOURCE_GROUP"

echo ""
echo "Checking if private endpoint exists..."
PE_COUNT=$(az network private-endpoint list \
  --resource-group $RESOURCE_GROUP \
  --query "[?contains(name, '$STORAGE_ACCOUNT')].{Name:name, IP:customDnsConfigs[0].ipAddresses[0]}" \
  --output table | grep -c "$STORAGE_ACCOUNT" || true)

if [ "$PE_COUNT" -gt 0 ]; then
  echo "✓ Private endpoint found for storage account"
  echo ""
  az network private-endpoint list \
    --resource-group $RESOURCE_GROUP \
    --query "[?contains(name, '$STORAGE_ACCOUNT')]" \
    --output table
else
  echo "✗ Private endpoint NOT found for storage account"
  exit 1
fi

echo ""
echo "Testing DNS resolution from AKS cluster..."

# Deploy a test pod to check DNS resolution
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: dns-test-pod
  namespace: default
spec:
  containers:
  - name: dns-test
    image: busybox:latest
    command: ["sleep", "300"]
  restartPolicy: Never
EOF

echo "Waiting for test pod to be ready..."
kubectl wait --for=condition=Ready pod/dns-test-pod --timeout=90s || true

echo ""
echo "Resolving storage account private endpoint from AKS pod..."
RESOLVED_IP=$(kubectl exec dns-test-pod -- nslookup ${STORAGE_ACCOUNT}.blob.core.windows.net 2>/dev/null | grep "^Address.*:" | tail -1 | awk '{print $NF}' || echo "FAILED")

echo "Resolved IP: $RESOLVED_IP"
echo "Expected Private IP: $PRIVATE_IP"

# Cleanup test pod
echo ""
echo "Cleaning up test pod..."
kubectl delete pod dns-test-pod --ignore-not-found=true

echo ""
if [ "$RESOLVED_IP" == "$PRIVATE_IP" ]; then
  echo "============================================"
  echo "✓ DNS resolution successful - AKS can resolve private endpoint"
  echo "✓ Private endpoint verification passed"
  echo "============================================"
  exit 0
else
  echo "============================================"
  echo "✗ DNS resolution mismatch"
  echo "✗ Private endpoint verification failed"
  echo "============================================"
  exit 1
fi
