#!/bin/bash
set -e

echo "============================================"
echo "Verifying CSI Drivers"
echo "============================================"

echo "Listing all CSI drivers in the cluster..."
kubectl get csidrivers

echo ""
echo "Checking for Azure Blob CSI driver..."
if kubectl get csidriver blob.csi.azure.com &>/dev/null; then
  echo "✓ Azure Blob CSI driver found"
else
  echo "✗ Azure Blob CSI driver NOT found"
  exit 1
fi

echo ""
echo "Checking for Azure Disk CSI driver..."
if kubectl get csidriver disk.csi.azure.com &>/dev/null; then
  echo "✓ Azure Disk CSI driver found"
else
  echo "✗ Azure Disk CSI driver NOT found"
  exit 1
fi

echo ""
echo "Checking for Azure File CSI driver..."
if kubectl get csidriver file.csi.azure.com &>/dev/null; then
  echo "✓ Azure File CSI driver found"
else
  echo "✗ Azure File CSI driver NOT found"
  exit 1
fi

echo ""
echo "============================================"
echo "✓ All CSI drivers verified successfully"
echo "============================================"
