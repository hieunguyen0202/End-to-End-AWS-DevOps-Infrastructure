# 📘 [AJ3] Github Action CICD Terraform Infra

Below is a complete GitHub Actions CI/CD pipeline to automate Terraform deployment for multiple environments (e.g., dev, uat, pre-prod) using environment-specific variable files.

## Goals
- Use a single Terraform codebase
- Deploy to dev, uat, or pre-prod based on Git branch
- Store environment-specific .tfvars and backend configuration
- Automate terraform init, plan, and apply securely

## 📁 Directory Structure

```
terraform/
├── modules/                # Reusable infrastructure modules
├── envs/
│   ├── dev/
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── uat/
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   └── pre-prod/
│       ├── backend.tf
│       └── terraform.tfvars
├── main.tf
├── variables.tf
└── .github/
    └── workflows/
        └── aj3-terraform-ci.yml

```

## 🚀 GitHub Actions CI/CD Workflow

```
# File: .github/workflows/aj3-terraform-ci.yml
name: Terraform CI/CD

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Select the environment to deploy'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - uat
          - pre-prod
      action:
        description: 'Select Terraform action'
        required: true
        default: 'create'
        type: choice
        options:
          - create
          - destroy


jobs:
  terraform:
    name: Terraform ${{ github.event.inputs.action }} on ${{ github.event.inputs.environment }}
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash

    env:
      AWS_REGION: ap-southeast-1

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.0

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Initialize Terraform
        run: |
          cd terraform/envs/${{ github.event.inputs.environment }}
          terraform init

      - name: Terraform Plan
        run: |
          cd terraform/envs/${{ github.event.inputs.environment }}
          terraform plan -var-file="terraform.tfvars"

      - name: Terraform Apply (dev/uat only)
        if: ${{ github.event.inputs.environment != 'pre-prod' && github.event.inputs.action == 'create' }}
        run: |
          cd terraform/envs/${{ github.event.inputs.environment }}
          terraform apply -var-file="terraform.tfvars" -auto-approve

      - name: Manual Approval Required (pre-prod)
        if: ${{ github.event.inputs.environment == 'pre-prod' && github.event.inputs.action == 'create' }}
        run: |
          echo "Manual approval required before applying to PRE-PROD."
          echo "Skipping auto-apply. Please review and apply manually if needed."
      
      - name: Terraform Destroy
        if: ${{ github.event.inputs.action == 'destroy' }}
        run: |
          cd terraform/envs/${{ github.event.inputs.environment }}
          terraform destroy -var-file="terraform.tfvars" -auto-approve


```

## 🛡️ GitHub Secrets Required

In your GitHub repo, add the following secrets under Settings > Secrets and variables > Actions:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

## 💡 CI/CD Workflow Explanation

| Component                 | Purpose                                                                                   |
|--------------------------|-------------------------------------------------------------------------------------------|
| `workflow_dispatch`      | Manually triggers the workflow with an environment dropdown (`dev`, `uat`, `pre-prod`).   |
| `terraform init`         | Initializes the backend configuration using each environment’s `backend.tf`.              |
| `terraform plan`         | Generates and shows an execution plan using the selected environment’s `.tfvars` file.    |
| `terraform apply`        | Automatically applies for `dev` and `uat`. For `pre-prod`, apply step is skipped (manual).|
| `inputs.environment`     | User-selected input to determine which environment to deploy (`dev`, `uat`, or `pre-prod`).|

