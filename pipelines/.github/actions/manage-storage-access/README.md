# Manage Storage Account Public Access Action

A reusable composite GitHub Action to manage Azure Storage Account public access for Terraform operations.

## Purpose

This action enables or disables public network access on Azure Storage Accounts. It's designed to work in conjunction with Terraform workflows where:
- Public access needs to be temporarily enabled for Terraform to manage storage resources
- Public access should be disabled after deployment for security (private endpoint only access)
- Public access needs to be re-enabled before destroying resources

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `action` | Action to perform: `enable` or `disable` | Yes | - |
| `storage_account_name` | Storage account name | No | `''` |
| `resource_group_name` | Resource group name | No | `''` |
| `retrieve_from_state` | Whether to retrieve names from Terraform state | No | `'true'` |

## Usage

### Enable Public Access (from Terraform state)

```yaml
- name: Enable Storage Account Public Access
  uses: ./.github/actions/manage-storage-access
  with:
    action: enable
    retrieve_from_state: 'true'
```

### Disable Public Access (from Terraform state)

```yaml
- name: Disable Storage Account Public Access
  uses: ./.github/actions/manage-storage-access
  with:
    action: disable
    retrieve_from_state: 'true'
```

### Enable Public Access (with explicit names)

```yaml
- name: Enable Storage Account Public Access
  uses: ./.github/actions/manage-storage-access
  with:
    action: enable
    storage_account_name: 'mystorageaccount'
    resource_group_name: 'myrg'
    retrieve_from_state: 'false'
```

## Prerequisites

- Azure CLI must be installed and authenticated
- For `retrieve_from_state: 'true'`:
  - Terraform must be initialized with access to the state
  - Terraform wrapper should be disabled (use `terraform_wrapper: false`)
  - Storage account and resource group names must be available as Terraform outputs

## Behavior

### Enable Action
1. Retrieves storage account details (from state or inputs)
2. Checks if storage account exists
3. If exists and public access is disabled:
   - Enables public network access
   - Sets default action to Allow
   - Waits 10 seconds for propagation
4. If already enabled, skips changes

### Disable Action
1. Retrieves storage account details (from state or inputs)
2. Checks if storage account exists
3. Disables public network access
4. Sets default action to Deny
5. Verifies the changes

## Error Handling

- Gracefully handles missing storage accounts (first deployment or already destroyed)
- Exits cleanly if details cannot be retrieved
- Suitable for use with `continue-on-error: true` in critical workflows
