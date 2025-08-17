# 📘 [AJ3] DevOps Project Documentation

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


- AWS Landing Zone

![alt text](EndToEnd-AWSLandingZone.drawio-1.png)

- Architecture Diagram: (AWS-JAVA-3TIER)

![alt text](<End-to-End.drawio (1).svg>)

## II. High-Level Architecture

### 🌐 AWS Account Structuring Overview:

```
AWS Organizations
│
├── Root Account
│
├── OU: Sandbox / Dev
│   └── AWS Account: dev-account
│
├── OU: Non-Prod
│   └── AWS Account: uat-account

```

- Dev Account: dùng bởi developers, ít hạn chế (nhưng vẫn theo IAM, guardrails)
- UAT Account: kiểm thử trước khi lên Prod, tách biệt hoàn toàn khỏi Dev


```
terraform-aws/
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── backend.tf (S3 bucket: dev-tf-state)
│   │   └── provider.tf (assume role to dev AWS account)
│   └── uat/
│       ├── main.tf
│       ├── variables.tf
│       ├── backend.tf (bucket: uat-tf-state)
│       └── provider.tf (assume role to uat AWS account)
├── modules/
│   ├── network-vpc/
│   └── ecs/
```

### 🌐 Backend State per environment:

envs/dev/backend.tf:

```
terraform {
  backend "s3" {
    bucket         = "dev-tf-state"
    key            = "vpc/main.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "dev-tf-lock"
    encrypt        = true
  }
}

```

envs/uat/backend.tf:

```
terraform {
  backend "s3" {
    bucket         = "uat-tf-state"
    key            = "vpc/main.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "uat-tf-lock"
    encrypt        = true
  }
}

```

### 🔁 Full Terraform Workflow Step-by-Step

- Developer tạo feature branch feature/add-s3-bucket
- Viết code trong module và folder envs/dev
- Push lên GitHub -> mở Pull Request vào branch dev
- CI Pipeline chạy:
  - terraform init -backend-config=... (dev)
  - terraform plan
  - Upload terraform plan output vào PR comment (CI/CD)

    ```
    - name: Terraform Plan
  id: plan
  run: |
    terraform plan -input=false -no-color > tfplan.txt

- name: Upload Plan to PR Comment
  uses: juliangruber/terraform-plan-commenter@v1.2.0
  with:
    plan: tfplan.txt
    github_token: ${{ secrets.GITHUB_TOKEN }}
    ```

- Reviewer approve → Merge vào branch dev
- CI của branch dev chạy terraform apply TỰ ĐỘNG lên môi trường DEV
- Khi DEV stable → tạo PR từ dev → main
- CI chạy plan cho môi trường UAT (envs/uat)
- Approve & merge → CI branch main chạy terraform apply lên UAT















### 🌐 Full Flow Overview:


```
User (Internet)
    ↓
CloudFront CDN (HTTPS, custom domain + caching)
    ↓
S3 Static Website (Frontend React / FE assets)
    ↓
Application Requests
    ↓
ALB (HTTP/HTTPS – public, gateway API routing)
    ↓
ECS Service (Backend API in private subnet)
    ↓
RDS (private DB subnet, port 3306)

```



### 🔐 Security Group Rules Overview

#### 📌 Public NLB Security Group (Public SG)

| **Direction** | **Type** | **Port** | **Source/Destination** | **Purpose**                                      |
|---------------|----------|----------|-------------------------|--------------------------------------------------|
| Inbound       | HTTP     | 80       | 0.0.0.0/0               | Allow traffic from the internet                  |
| Outbound      | HTTP     | 80       | NGINX SG                | Forward request to NGINX reverse proxy           |

---


#### 📌 Private NLB Security Group

| **Direction** | **Type** | **Port** | **Source/Destination** | **Purpose**                                      |
|---------------|----------|----------|-------------------------|--------------------------------------------------|
| Inbound       | HTTP     | 8080     | NGINX SG                | Accept traffic from NGINX                        |
| Outbound      | HTTP     | 8080     | ECS Task SG             | Forward to ECS application container             |

---

#### 📌 ECS Task Security Group

| **Direction** | **Type** | **Port** | **Source/Destination** | **Purpose**                                      |
|---------------|----------|----------|-------------------------|--------------------------------------------------|
| Inbound       | HTTP     | 8080     | Private NLB SG          | Accept traffic from Private NLB                  |
| Outbound      | All      | All      | 0.0.0.0/0               | Allow internet and DB access                     |

---

#### 📌 Private DB Security Group

| **Direction** | **Type**    | **Port** | **Source/Destination** | **Purpose**                                      |
|---------------|-------------|----------|-------------------------|--------------------------------------------------|
| Inbound       | MySQL/Aurora| 3306     | ECS Task SG             | Accept DB queries from ECS task                  |
| Outbound      | All         | All      | 0.0.0.0/0               | Allow system updates, DNS, etc.                  |




## III. High-Level Goals for 99.95% SLA

### Availability & Resilience Strategy

| **Area**              | **Objective**                                                       |
|-----------------------|---------------------------------------------------------------------|
| **High Availability** | Avoid single points of failure (use Multi-AZ & AutoFailover)       |
| **Data Durability**   | Enable automated backups and cross-region replication              |
| **Minimal Downtime**  | Use safe deployment strategies (`create_before_destroy`)           |
| **Disaster Recovery** | Define and test DR runbooks (manual + automated recovery)          |
| **Monitoring & Alerts** | Detect failures fast with alarms and metrics                     |


### Multi-AZ RDS for High Availability

#### ☑️ Terraform Task

- Use multi_az = true in your RDS configuration.
- Choose instance class that supports Multi-AZ (e.g., db.m6g.large or above).

```
resource "aws_db_instance" "primary" {
  identifier         = "app-prod-db"
  engine             = "mysql"
  instance_class     = "db.m6g.large"
  multi_az           = true
  ...
}
```

#### ☑️ Outcome

- Failover to standby in the other AZ within 1–2 minutes.
- AWS manages data replication between AZs.


### Cross-Region Backups

#### ☑️ Terraform Task

- Enable `backup_retention_period` and `copy_tags_to_snapshot`
- Use `aws_db_snapshot` and `aws_db_snapshot_copy` for cross-region copies.

```
resource "aws_db_snapshot_copy" "cross_region" {
  source_db_snapshot_identifier = aws_db_snapshot.primary_snapshot.id
  target_db_snapshot_identifier = "db-copy-${timestamp()}"
  kms_key_id                    = aws_kms_key.replica.arn
  source_region                 = var.primary_region
}
```

#### ☑️ Outcome
- Backups stored securely in another region for DR readiness.

### Safe Deployments with create_before_destroy

#### ☑️ Terraform Task

- Use lifecycle blocks on resources like:
  - Security groups
  - IAM roles
  - Subnets / route tables
  - NLBs
  - EC2 instances

```
resource "aws_security_group" "db_sg" {
  name = "db-sg"

  lifecycle {
    create_before_destroy = true
  }
}

```

#### ☑️ Outcome

- Avoids downtime when updating critical infra like SGs or route tables.

### Disaster Recovery (DR) Playbook

#### ☑️ Manual or Automated Steps

- Document procedures to restore from cross-region snapshot:
  - Launch RDS from snapshot
  - Update DNS or failover route in Route 53
- Terraform module to quickly stand up infrastructure in secondary region

#### ☑️ Automation Tip:
- Use `terraform workspace` or terragrunt to replicate infra to secondary region.


### Monitoring, Alarms, and Failover Automation

- Use CloudWatch Alarms:
  - RDS status checks
  - Freeable memory, CPU, storage thresholds

```
resource "aws_cloudwatch_metric_alarm" "aurora_cpu_high" {
  count               = var.db_mode == "aurora" ? 1 : 0
  alarm_name          = "aurora-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when Aurora CPU exceeds 80%"
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora[0].id
  }
  alarm_actions       = [var.sns_topic_arn]  # Send notifications
}

resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  count               = var.db_mode == "aurora" ? 1 : 0
  alarm_name          = "aurora-replica-lag-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 60 # seconds
  alarm_description   = "Alarm when Aurora Replica lag exceeds 60 seconds"
  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.aurora[0].id
  }
  alarm_actions       = [var.sns_topic_arn]
}


```

- CloudWatch Metrics for RDS/Aurora

AWS RDS/Aurora automatically sends key performance and health metrics to CloudWatch, including:

| Metric               | Description                      | Why monitor it?                   |
|----------------------|---------------------------------|---------------------------------|
| CPUUtilization       | % of CPU used                   | Detect high load / bottlenecks  |
| FreeableMemory       | Available RAM (bytes)           | Prevent out-of-memory errors    |
| DatabaseConnections  | Number of active DB connections | Avoid connection saturation     |
| FreeStorageSpace     | Free disk space available       | Avoid running out of disk       |
| ReadIOPS / WriteIOPS | I/O operations per second       | Check for unusual or high I/O load |
| ReadLatency / WriteLatency | Time taken for read/write operations | Detect slow queries or storage issues |
| ReplicaLag           | Lag time of replicas (Aurora only) | Ensure replicas are up-to-date |
| DiskQueueDepth       | Number of pending IO requests   | Identify storage bottlenecks    |
| SwapUsage            | Swap space used                 | Can indicate memory pressure    |


- In a real project, how would you apply CloudWatch for RDS/Aurora?
  - Baseline Metrics & Thresholds: Understand your workload baseline (normal CPU, memory, IOPS). Set thresholds slightly above baseline.

  - Create Alarms for Key Metrics: CPU, storage space, connections, replica lag, latency.

  - Setup Notifications: Use SNS to send alerts to DevOps team via email, Slack, PagerDuty.

  - Automated Actions (optional): Use CloudWatch Event Rules + Lambda to automate scale up/down, or perform remediation.

  - Dashboards: Create CloudWatch Dashboards to visualize trends and performance in one place.

  - Logs: Enable enhanced monitoring & export RDS logs (slow query logs, error logs) to CloudWatch Logs for deeper insights.

  - Integrate with CI/CD: Use alarms as gates to halt deployments if DB performance is degraded.



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
    aj3-terraform-ci.yml
    aj3-build-cicd.yml

```

#### Documentation for CICD

[📘 How to setup terraform with Ansible ](https://devopsvn.tech/terraform-series/terraform/bai-13-ansible-with-terraform)

[📘 Dependencies Installation ](docs/AJ3-prequisite-setup.md)

[📘 Github Action CICD Terraform Infra](docs/AJ3-CICD-Infra.md)

[📘 Github Action CICD for Build Docker Image](docs/AJ3-CICD-build.md)


### 2. Terraform Infrastructure Modules

🔹 Overview

All infrastructure is provisioned as modular Terraform code.

🔸 Modules Breakdown

#### 📦 Terraform Module Overview

| Module         | Purpose                                                         |
|----------------|-----------------------------------------------------------------|
| `network`          | Create VPC, public/private subnets, IGW, NAT, and route tables, Transit Gateway  |
| `security`     | Define and attach Security Groups  |
| `bastion`      | Launch EC2 instance in public subnet for SSH access |
| `nginx`        | Deploy EC2 instance for static frontend (Nginx server), install sonarqube server          |
| `database`     | Provision RDS (MySQL) with Multi-AZ, Amazon MQ (e.g., ActiveMQ), Memcached via ElastiCache |
| `autoscaling`  | Set up Auto Scaling Group for application servers               |
| `nlb`          | Configure public/private Network Load Balancers                 |
| `iam`          | Create IAM roles and policies for EC2, ECS, and other services  |
| `ecs`          | Create ECS cluster |



#### 📁 Recommended Structure:

```
terraform/
├── modules/
│   └── network/
│       └── main.tf        
│   └── bastion/
│       └── main.tf        
│   └── ecs/
│       └── main.tf        
│   └── security/
│       └── main.tf        
│   └── database/
│       └── main.tf        
├── envs/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   ├── uat/
│   │   ├── backend.tf
│   │   └── terraform.tfvars
│   └── pre-prod/
│       ├── backend.tf
│       └── terraform.tfvars
└── variables.tf           # Common variable definitions

```
#### Terraform design module

![alt text](aj3-terraform-module-design.drawio.png)


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

