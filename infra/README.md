# Infrastructure

This directory contains all Terraform infrastructure code organized by environment.

## Structure

```
infra/
└── environment/
    └── dev/                        # Development environment
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── terraform.tfvars.example
        ├── backend.tfvars.example
        ├── modules/                # Terraform modules
        ├── tests/                  # Test scripts
        └── examples/               # Example K8s manifests
```

## Environments

### Dev
The development environment contains a complete AKS setup with CSI storage integration and private endpoints.

Location: `environment/dev/`

## Working with Infrastructure

Navigate to the specific environment directory before running Terraform commands:

```bash
cd infra/environments/dev
terraform init -backend-config="backend.tfvars"
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
```

## Adding New Environments

To add a new environment (e.g., staging, production):

1. Create a new directory under `environment/` (e.g., `environment/staging`)
2. Copy the Terraform files from `dev/`
3. Update the `terraform.tfvars` with environment-specific values
4. Configure a separate backend for state isolation

## Documentation

For complete setup and deployment instructions, see the [main README](../../README.md) and [SOLUTION.md](../../SOLUTION.md).
