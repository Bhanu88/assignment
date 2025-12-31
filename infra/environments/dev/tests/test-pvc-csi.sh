#!/bin/bash
set -e

# Arguments
STORAGE_ACCOUNT=$1
STORAGE_CONTAINER=${2:-"aks-storage"}
STORAGE_ACCOUNT_KEY=$3

if [ -z "$STORAGE_ACCOUNT" ]; then
  echo "Usage: $0 <storage_account_name> [container_name] [storage_account_key]"
  exit 1
fi

echo "============================================"
echo "Testing PVC Creation with CSI Driver"
echo "============================================"

echo "Storage Account: $STORAGE_ACCOUNT"
echo "Container: $STORAGE_CONTAINER"

# Create namespace for testing
NAMESPACE="csi-test"
echo ""
echo "Creating test namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Create storage account secret if key is provided
if [ -n "$STORAGE_ACCOUNT_KEY" ]; then
  echo "Creating storage account secret..."
  kubectl create secret generic azure-storage-secret \
    --namespace=$NAMESPACE \
    --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT \
    --from-literal=azurestorageaccountkey=$STORAGE_ACCOUNT_KEY \
    --dry-run=client -o yaml | kubectl apply -f -
fi

echo ""
echo "Creating PersistentVolume with Azure Blob CSI driver..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-blob-csi-test
  namespace: $NAMESPACE
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  storageClassName: azureblob-nfs-premium
  csi:
    driver: blob.csi.azure.com
    volumeHandle: ${STORAGE_ACCOUNT}#${STORAGE_CONTAINER}
    volumeAttributes:
      containerName: $STORAGE_CONTAINER
      protocol: nfs
EOF

echo ""
echo "Creating PersistentVolumeClaim..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-blob-csi-test
  namespace: $NAMESPACE
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azureblob-nfs-premium
  resources:
    requests:
      storage: 10Gi
  volumeName: pv-blob-csi-test
EOF

echo ""
echo "Waiting for PVC to be bound..."
sleep 5
PVC_STATUS=$(kubectl get pvc pvc-blob-csi-test -n $NAMESPACE -o jsonpath='{.status.phase}')

echo "PVC Status: $PVC_STATUS"

if [ "$PVC_STATUS" == "Bound" ]; then
  echo "✓ PVC successfully bound"
else
  echo "⚠ PVC status is: $PVC_STATUS (may need more time or configuration)"
fi

echo ""
echo "Creating test pod using the PVC..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: pvc-test-pod
  namespace: $NAMESPACE
spec:
  containers:
  - name: test-container
    image: nginx:latest
    volumeMounts:
    - name: blob-storage
      mountPath: /mnt/blob
  volumes:
  - name: blob-storage
    persistentVolumeClaim:
      claimName: pvc-blob-csi-test
EOF

echo ""
echo "Waiting for pod to be ready..."
kubectl wait --for=condition=Ready pod/pvc-test-pod -n $NAMESPACE --timeout=120s || true

POD_STATUS=$(kubectl get pod pvc-test-pod -n $NAMESPACE -o jsonpath='{.status.phase}')
echo "Pod Status: $POD_STATUS"

echo ""
echo "Checking pod events..."
kubectl describe pod pvc-test-pod -n $NAMESPACE | grep -A 10 "Events:"

echo ""
echo "============================================"
echo "Cleanup Test Resources"
echo "============================================"

read -p "Do you want to cleanup test resources? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Deleting test resources..."
  kubectl delete pod pvc-test-pod -n $NAMESPACE --ignore-not-found=true
  kubectl delete pvc pvc-blob-csi-test -n $NAMESPACE --ignore-not-found=true
  kubectl delete pv pv-blob-csi-test --ignore-not-found=true
  kubectl delete namespace $NAMESPACE --ignore-not-found=true
  echo "✓ Cleanup completed"
else
  echo "Skipping cleanup. To cleanup later, run:"
  echo "  kubectl delete namespace $NAMESPACE"
fi

echo ""
echo "============================================"
echo "✓ PVC CSI Driver test completed"
echo "============================================"
