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
  push:
    branches:
      - dev
      - uat
      - pre-prod

jobs:
  terraform:
    name: Terraform Deploy
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash

    env:
      AWS_REGION: us-east-1

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

      - name: Set environment-specific variables
        id: vars
        run: |
          ENV_NAME=$(echo "${GITHUB_REF##*/}")
          echo "env_name=$ENV_NAME" >> "$GITHUB_OUTPUT"

      - name: Initialize Terraform
        run: |
          cd terraform/envs/${{ steps.vars.outputs.env_name }}
          terraform init

      - name: Terraform Plan
        run: |
          cd terraform/envs/${{ steps.vars.outputs.env_name }}
          terraform plan -var-file="terraform.tfvars"

      - name: Terraform Apply
        if: github.ref != 'refs/heads/pre-prod'  # Auto-apply only for dev and uat
        run: |
          cd terraform/envs/${{ steps.vars.outputs.env_name }}
          terraform apply -var-file="terraform.tfvars" -auto-approve

      - name: Terraform Manual Approval for PRE-PROD
        if: github.ref == 'refs/heads/pre-prod'
        run: echo "Manual approval required before applying to PRE-PROD"

```

## 🛡️ GitHub Secrets Required

In your GitHub repo, add the following secrets under Settings > Secrets and variables > Actions:

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

## 💡 CI/CD Workflow Explanation

| Component             | Purpose                                                                 |
|----------------------|-------------------------------------------------------------------------|
| `push: branches:`     | Triggers deployment when changes are pushed to `dev`, `uat`, or `pre-prod`. |
| `terraform init`      | Initializes backend config from each environment’s `backend.tf`.         |
| `terraform plan/apply`| Uses each environment’s `.tfvars` file to apply the Terraform configuration. |
| Conditional apply     | Auto-applies changes for `dev` and `uat`; manual approval recommended for `pre-prod`. |
