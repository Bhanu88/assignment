# Azure AKS with CSI Storage - Complete Solution

## Overview

This repository provides a production-ready Terraform solution for deploying Azure Kubernetes Service (AKS) with:

- **CSI Storage Integration** - All Azure storage drivers (Blob, Disk, File)
- **Private Endpoint Security** - Zero public access to storage
- **RBAC Configuration** - Least privilege access control
- **Automated CI/CD** - GitHub Actions with security automation
- **Modular Architecture** - Reusable components and test scripts
- **Security Best Practices** - Automated public access management

## Quick Links

- [Complete Solution Documentation](SOLUTION.md)
- [Azure AD Group Setup](AD-GROUP-SETUP.md)
- [Testing Guide](infra/environments/dev/tests/README.md)
- [Storage Examples](infra/environments/dev/examples/README.md)
- [GitHub Actions Workflow](.github/workflows/terraform.yml)
- [pipelines Documentation](pipelines/README.md)

## Key Features

### Security Automation
- **Automated Public Access Control**: Storage account public access is automatically managed:
  - Temporarily enabled before Terraform plan/apply
  - Automatically disabled after deployment for private-only access
  - Re-enabled before destruction to allow cleanup
- **Private Endpoint Only**: All storage access routed through private endpoints
- **Zero Trust Architecture**: No public internet access to storage resources

### Modular Design
- **Reusable Actions**: Custom GitHub Actions for common operations
- **Test Scripts**: Independent verification scripts in `/tests` folder
- **Terraform Modules**: Organized by resource type (AKS, Storage, Networking, RBAC)

### CI/CD pipelines
- **GitHub Actions Workflow**: Complete automation with:
  - Validation → Prepare Storage → Plan → Apply → Verify → Destroy
  - Conditional execution (skip plan/apply when destroying)
  - Automated security hardening
  - Comprehensive verification tests

