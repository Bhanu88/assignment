# Pipeline

This directory contains reference documentation and backup copies of CI/CD pipeline configurations.

**Note:** GitHub Actions requires workflows to be in `.github/workflows/` at the repository root. The active workflows are located at the root level, while this directory serves as documentation and reference.

## Active Workflow Location

The active GitHub Actions workflow is located at:
- **`.github/workflows/terraform.yml`** (repository root)
- **`.github/actions/manage-storage-access/`** (repository root)

## Structure

```
Root level (.github/):              # Active GitHub Actions (required by GitHub)
├── workflows/
│   └── terraform.yml               # Active workflow
└── actions/
    └── manage-storage-access/      # Active composite action

This directory (pipeline/):         # Reference and documentation
└── .github/
    ├── workflows/
    │   └── terraform.yml           # Reference copy
    └── actions/
        └── manage-storage-access/  # Reference copy
            ├── action.yml
            └── README.md
```

## GitHub Actions Workflow

The main workflow (`terraform.yml`) handles the complete lifecycle of the AKS infrastructure:

1. **Validation** - Terraform format and validation
2. **Prepare Storage** - Manage storage account public access
3. **Plan** - Generate Terraform execution plan
4. **Apply** - Deploy infrastructure
5. **Verify** - Run automated tests
6. **Destroy** - Clean up resources (optional)

All Terraform commands run in the `infra/environments/dev/` directory using the `working-directory` setting.

## Custom Actions

### manage-storage-access

A reusable composite action that manages Azure Storage account public access settings for secure deployment.

See [../.github/actions/manage-storage-access/README.md](../.github/actions/manage-storage-access/README.md) for details.

## Usage

The workflows are automatically triggered by:
- Push to `main` or `feature/*` branches (if Terraform files change)
- Pull requests to `main`
- Manual workflow dispatch

For full documentation, see the [main README](../README.md).
