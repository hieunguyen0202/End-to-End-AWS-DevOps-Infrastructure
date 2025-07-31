# 📘 DevOps Project Documentation

## I. Project Overview

- Project Name: End to End AWS DevOps Infrastructure

- Objective: Automate the build, deployment, and infrastructure provisioning of a Java-based 3-tier web application using CI/CD pipelines and Infrastructure as Code (IaC).

- Key values:
    - Built modular Terraform infrastructure for DEV/UAT/DR, enabling version-controlled, repeatable deployments. Optimized provisioning, reduced manual effort, improved consistency, and ensured high availability across AZs with autoscaling, NAT, ECS, and ALBs.
    - Implemented CI/CD pipeline via GitHub Actions, deploying Java microservices to ECS Fargate with JFrog Artifactory and version tagging, enhancing deployment speed, ensuring release traceability, minimizing human error, and improving delivery consistency across environments.
    - Enhanced infrastructure security by enforcing IAM and security groups via Terraform, minimizing exposure through strict private/public segmentation, detecting code and dependency vulnerabilities with SonarQube and JFrog Xray to reduce attack surface and ensure compliance.
    - Enabled high availability and disaster recovery by configuring multi-AZ RDS (MySQL) with automated backups, cross-region snapshot replication, and structured DR playbooks to meet SLA uptime target of 99.95%.
    - Enforced centralized monitoring and alerting using AWS CloudWatch Alarms, AWS CloudTrail, and VPC Flow Logs to track resource health, container behavior, and suspicious activity—enhancing observability and response readiness across all environments.

- Tech Stack: GitHub Actions, Terraform, Docker, ECS, ECR, SonarCloud, JFrog, RDS (MySQL), Amazon MQ, ElastiCache (Memcached), CloudWatch, CloudFront, ALB, Nginx, Tomcat, Maven.

- Architecture Diagram: (AWS-JAVA-3TIER)

![alt text](End-to-End-AWS-DevOps-Infrastructure.drawio.svg)


## II. High-Level Architecture

Provide a visual representation of:

- CI/CD Pipeline
- Frontend (Static App on Nginx)
- Backend (Java App on ECS)
- RDS Database Tier
- Messaging, Caching
- VPC, Subnets, NAT, IGW, Transit Gateway
- Monitoring & Logging
- Security (IAM, SGs, Encryption)


## III. Repository Structure


## IV. Module Documentation

### 1. CI/CD Pipeline (GitHub Actions)

🔹 Overview

This pipeline automates build, code scanning, artifact management, image building, security scanning, and deployment to ECS and Nginx.

🔸 Workflow Steps:

Backend (Java):

- Checkout source code from GitHub
- Run SonarCloud scan
- Build with Maven
- Push artifacts to JFrog Artifactory
- Build Docker image
- Scan image with Trivy
- Push to AWS ECR
- Deploy image to ECS

Frontend (Static):

- Checkout frontend code
- Build static files (React/Angular/etc.)
- Copy build output to Nginx EC2 server via SSH or deploy with S3 + CloudFront

#### 📁 GitHub Actions Folder Structure:

```
.github/
  workflows/
    build-backend.yml
    deploy-backend.yml
    build-frontend.yml
    deploy-frontend.yml

```

### 2. Terraform Infrastructure Modules

🔹 Overview

All infrastructure is provisioned as modular Terraform code.

🔸 Modules Breakdown

#### 📦 Terraform Module Overview

| Module         | Purpose                                                         |
|----------------|-----------------------------------------------------------------|
| `vpc`          | Create VPC, public/private subnets, IGW, NAT, and route tables  |
| `transit-gateway` | Set up Transit Gateway and attach to VPCs                     |
| `security`     | Define and attach Security Groups                               |
| `bastion`      | Launch EC2 instance in public subnet for SSH access             |
| `nginx`        | Deploy EC2 instance for static frontend (Nginx server)          |
| `rds`          | Provision RDS (MySQL) with Multi-AZ                             |
| `mq`           | Set up Amazon MQ (e.g., ActiveMQ)                               |
| `elasticache`  | Deploy Memcached via ElastiCache                                |
| `autoscaling`  | Set up Auto Scaling Group for application servers               |
| `nlb`          | Configure public/private Network Load Balancers                 |
| `iam`          | Create IAM roles and policies for EC2, ECS, and other services  |


#### 📁 Recommended Structure:

```
terraform/
├── modules/
│   └── network/
│       └── main.tf        # Reusable module for VPC, Subnets, etc.
│   └── bastion/
│       └── main.tf        # Reusable module for EC2, VM, etc.
│   └── ecs-cluster/
│       └── main.tf        # Reusable module for ECS, etc.
│   └── security/
│       └── main.tf        # Reusable module for IAM, Security Group etc.
│   └── storage/
│       └── main.tf        # Reusable module for database, memcached etc.
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── uat/
│   │   └── ...
│   └── pre-prod/
│       └── ...
└── variables.tf           # Common variable definitions

```

#### Create Separate Environments with Workspaces

To use workspaces, eg. DEV environment

```
terraform workspace new dev
terraform workspace select dev
terraform apply -var-file="envs/dev/terraform.tfvars"

```

#### Use Environment-specific Variables

```
env_name       = "dev"
vnet_name      = "dev-vnet"
address_space  = "10.0.0.0/16"
location       = "East US"
resource_group = "rg-dev"

```

#### Use Separate Backends

For state separation across environments, define different backends.

Eg. `envs/dev/backend.tf`

```
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"   
    key            = "dev/terraform.tfstate"        
    region         = "us-east-1"                    
    dynamodb_table = "terraform-locks"              
    encrypt        = true                           
  }
}

```


### 3. Golden AMI Creation

🔹 Overview

Custom AMIs are created to speed up instance launch and enforce consistency.

🔸 Global Base AMI

Install: AWS CLI, CloudWatch Agent, SSM Agent

🔸 Specialized AMIs:

- Nginx AMI: Install nginx, configure memory metrics
- Tomcat AMI: Install Tomcat, Java 11, systemd setup
- Maven Build AMI: Install Maven, Git, Java 11, preconfigure environment

📌 Optionally use Packer for automation.

### 4. Monitoring & Logging

#### 🔍 Monitoring & Logging

| Tool           | Purpose                                                                 |
|----------------|-------------------------------------------------------------------------|
| `CloudWatch`   | Log and metric collection for EC2, RDS, and application components       |
| `Cronjob + S3` | Push Tomcat logs to S3 and rotate local logs to save disk space         |
| `Alarms`       | Trigger email alerts on threshold breaches (e.g., DB connections > 100) |
| `SNS`          | Send notifications via Email/SMS when alarms are triggered              |


### 5. Application Lifecycle

#### 🔄 Application Lifecycle

| Phase                   | Tasks                                                                 |
|-------------------------|-----------------------------------------------------------------------|
| `Pre-Deployment`        | Build custom AMIs, configure monitoring agents, SonarCloud & JFrog setup |
| `Infrastructure Deployment` | Run Terraform pipelines to provision AWS infrastructure               |
| `CI/CD Execution`       | Build, scan, and deploy applications using GitHub Actions workflows   |
| `Post-Deployment`       | Set up CloudWatch alerts, validate deployment, and configure log rotation |


## VI. Security Best Practices

- Store secrets in GitHub Secrets or AWS Parameter Store
- Use IAM roles, avoid access keys in pipelines
- Principle of Least Privilege (SGs, IAM, S3 access)
- S3 VPC Endpoint instead of public access
- Enable logging: CloudTrail, VPC Flow Logs

