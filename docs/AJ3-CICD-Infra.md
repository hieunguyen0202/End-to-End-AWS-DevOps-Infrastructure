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