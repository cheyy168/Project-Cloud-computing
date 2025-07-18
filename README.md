# Project-Cloud-computing
# Cyber Security Trends 2025 - AWS Infrastructure

This project deploys a scalable web infrastructure on AWS to host a static website showcasing "10 Cyber Security Trends For 2025". The architecture includes VPC networking, EC2 auto-scaling, Application Load Balancer, S3 static hosting, and monitoring components.

## Architecture Overview

![Architecture Diagram]https://cyber-trends-static-assets-dev-007536ca.s3.us-west-2.amazonaws.com/images/image.png

The infrastructure consists of:
- **VPC** with public subnets across multiple AZs
- **Application Load Balancer** distributing traffic
- **Auto Scaling Group** of EC2 instances running Apache HTTPD
- **S3 Bucket** for static assets with public read access
- **CloudWatch Alarms** for auto-scaling triggers
- **IAM Roles** with least-privilege permissions

## Features

- **High Availability**: Multi-AZ deployment with auto-scaling
- **Scalability**: Automatically adjusts capacity based on CPU utilization
- **Security**: HTTPS (to be implemented), IAM roles with minimal permissions
- **Cost Optimization**: Scales in during low traffic periods
- **Static Content Delivery**: S3 website hosting for efficient content delivery

## Terraform Modules

The infrastructure is defined in these Terraform files:

1. **main.tf** - Core configuration and providers
2. **vpc.tf** - Networking components (VPC, subnets, IGW, route tables)
3. **ec2.tf** - Compute resources (Launch Template, Auto Scaling Group)
4. **alb.tf** - Load balancing components
5. **s3.tf** - Static assets storage and website hosting
6. **security.tf** - Security groups and IAM policies
7. **cloudwatch.tf** - Monitoring and auto-scaling policies
8. **outputs.tf** - Deployment outputs
9. **variables.tf** - Configurable parameters