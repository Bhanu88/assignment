# Total Cost of Ownership (TCO) - Azure Infrastructure

## Overview
This document provides a detailed cost analysis for the Azure Kubernetes Service (AKS) infrastructure deployed in **West Europe** region based on the current Terraform configuration.

---

## Monthly Cost Breakdown (West Europe Region)

### 1. **AKS Cluster** - ~€146.84/month
- **Control Plane**: Free (Standard tier)
- **Compute (2 nodes × Standard_D2s_v3)**:
  - 2 vCPUs, 8 GB RAM per node
  - €0.101/hour × 2 nodes × 730 hours = **€147.46/month**
- **With autoscaling enabled** (2-5 nodes):
  - Minimum (2 nodes): €147.46/month
  - Maximum (5 nodes): €368.65/month
  - **Average cost (3 nodes)**: €221.19/month

### 2. **Storage Account** - ~€0.50-€2.00/month
- **Standard LRS Blob Storage**:
  - First 50 TB: €0.0166/GB/month
  - Estimated 10 GB usage: **€0.17/month**
- **Operations** (PUT/List/Create): ~€0.20/month
- **Versioning & Retention**: +€0.10/month
- **Estimated Total**: **€0.50-€2.00/month** (depending on usage)

### 3. **Log Analytics Workspace** - ~€10-€50/month
- **Data Ingestion**: €2.30/GB
- **Estimated 5-10 GB/month** (Container Insights, metrics, logs): **€11.50-€23.00/month**
- **Data Retention**: First 31 days free, then €0.10/GB/month
- **Estimated Total**: **€10-€50/month** (varies with cluster activity)

### 4. **Networking** - ~€5-€15/month
- **Virtual Network**: Free
- **Private Endpoint**: €0.0073/hour × 730 hours = **€5.33/month**
- **Private DNS Zone**: €0.45/zone/month = **€0.45/month**
- **Data Processing** (Private Link): €0.0073/GB (first 1 TB)
  - Estimated 100 GB: **€0.73/month**
- **NSG**: Free
- **Estimated Total**: **€6.51-€15/month**

### 5. **Container Insights** - Included in Log Analytics

### 6. **RBAC & Azure AD** - Free

---

## Total Monthly Cost Summary

| Scenario | Monthly Cost (EUR) | Annual Cost (EUR) |
|----------|-------------------|-------------------|
| **Minimum (2 nodes)** | €165-€215 | €1,980-€2,580 |
| **Average (3 nodes)** | €238-€288 | €2,856-€3,456 |
| **Maximum (5 nodes)** | €390-€440 | €4,680-€5,280 |

---

## Cost Optimization Recommendations

#### 1. **Use Azure Spot Instances** - Save up to 80%

#### 2. **Reserved Instances** - Save up to 72%
#### 3. **Optimize Storage**
#### 4. **Use Burstable B-series VMs** (if workload permits)
#### 5. **Enable Cluster Autoscaler with tight limits**
#### 6. **Optimize Log Analytics**
#### 7. **Use Azure Hybrid Benefit**
#### 8. **Right-size VMs**


## Cost Tracking

Last Updated: December 30, 2025  
Currency: EUR (€)  
Region: West Europe  
Pricing Tier: Pay-as-you-go 

---

## Additional Resources

- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [Azure Cost Management Documentation](https://docs.microsoft.com/en-us/azure/cost-management-billing/)
- [AKS Pricing Details](https://azure.microsoft.com/en-us/pricing/details/kubernetes-service/)
- [Azure Storage Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/blobs/)
- [Log Analytics Pricing](https://azure.microsoft.com/en-us/pricing/details/monitor/)
