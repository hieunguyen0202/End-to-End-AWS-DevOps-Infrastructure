# AWS-Infra-03-RDSCacheMQBeanstalkInfra

![alt text](AWS-Infra-03-RDSCacheMQBeanstalkInfra.drawio.svg)

# Application Overview

🔹 Frontend & Network Entry
- CloudFront

Purpose: Acts as a CDN (Content Delivery Network) to cache and distribute content globally, reducing latency and improving performance for users.

- Application Load Balancer (ALB)

Purpose: Distributes incoming HTTP/HTTPS traffic across multiple instances in the Auto Scaling Group to ensure high availability and fault tolerance.

- Internet Gateway

Purpose: Allows communication between instances in the public subnet and the internet.

🔹 Networking & Routing
- VPC (Virtual Private Cloud)

Purpose: Isolates and controls network settings for all resources, enhancing security.

- Public Subnets

Purpose: Host internet-facing resources like the ALB and NAT Gateway.

- Private Subnets

Purpose: Host backend services like application servers, databases, MQ, and caching, not directly exposed to the internet.

- Route Tables

Purpose: Manage routing between subnets, S3, and the internet.

- NAT Gateway

Purpose: Allows instances in the private subnet to access the internet (e.g., to download updates) without exposing them directly.

- S3 Gateway Endpoint

Purpose: Enables private network access to Amazon S3 without using the Internet Gateway, improving security and reducing data transfer costs.

🔹 Compute Layer
- Auto Scaling Group (ASG)

Purpose: Automatically adds/removes EC2 instances based on demand, ensuring scalability and high availability of the application layer.

🔹 Application Integration
- Amazon MQ

Purpose: Managed message broker (e.g., ActiveMQ or RabbitMQ) used to decouple application components and manage asynchronous communication.

- Memcached (Amazon ElastiCache)

Purpose: Provides in-memory data caching to reduce database load and increase application performance.

🔹 Data Storage
- Amazon RDS

Purpose: Managed relational database service used to store application data (e.g., MySQL, PostgreSQL, etc.) with high availability and automated backups.

- Amazon S3

Purpose: Object storage for storing static assets, backups, deployment artifacts, logs, and other large files.

🔹 Monitoring & Alerting
- Amazon CloudWatch

Purpose: Monitors logs, metrics, and events; used to trigger alarms based on defined thresholds.

- CloudWatch Alarms

Purpose: Watch specific metrics and trigger actions (e.g., scale out or send notifications).

- SNS Topic (Simple Notification Service)

Purpose: Sends alerts via email, SMS, or other protocols when an alarm is triggered (e.g., CPU usage exceeds threshold).

🔹 Security
- Security Groups

Purpose: Acts as virtual firewalls for controlling inbound/outbound traffic for EC2, ALB, Amazon MQ, and RDS.

# Implement Plan

- Access source demo application
- Write Terraform template to deploy IaC
- How to use Github Action to auto IaC
- 