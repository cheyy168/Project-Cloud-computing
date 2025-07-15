# variables.tf - Enhanced with validation, consistency, and west region support

### AWS Configuration
variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-west-2"

  validation {
    condition     = contains(["us-east-1", "us-west-2", "eu-west-1"], var.region)
    error_message = "Valid values for region: us-east-1, us-west-2, eu-west-1."
  }
}

### Project Metadata
variable "project_name" {
  description = "Name of the project (used for resource naming and tagging)"
  type        = string
  default     = "cyber-trends"

  validation {
    condition     = length(var.project_name) <= 16 && can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must be lowercase alphanumeric with hyphens, max 16 chars."
  }
}

variable "environment" {
  description = "Deployment environment tier (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Valid values: dev, staging, prod."
  }
}

### Network Configuration
variable "vpc_cidr" {
  description = "Primary CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "Map of public subnets with CIDR blocks and availability zones"
  type = map(object({
    cidr_block = string
    az         = string
  }))

  default = {
    public_subnet_1 = {
      cidr_block = "10.0.1.0/24"
      az         = "us-west-2a"
    }
    public_subnet_2 = {
      cidr_block = "10.0.2.0/24"
      az         = "us-west-2b"
    }
  }
}

### Auto Scaling Configuration
variable "instance_type" {
  description = "EC2 instance type for web servers"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = contains(["t2.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Valid instance types: t2.micro, t3.small, t3.medium."
  }
}

variable "min_size" {
  description = "Minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 2

  validation {
    condition     = var.min_size >= 1 && var.min_size <= 10
    error_message = "Must be between 1 and 10."
  }
}

variable "max_size" {
  description = "Maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 4

  validation {
    condition     = var.max_size >= 1 && var.max_size <= 10
    error_message = "Must be between 1 and 10."
  }
}

variable "desired_capacity" {
  description = "Desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_capacity >= 1 && var.desired_capacity <= 10
    error_message = "Must be between 1 and 10."
  }
}

### Common Tags
variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    Project     = "cyber-trends"
    Environment = "dev"
    Terraform   = "true"
    Owner       = "devops-team"
  }
}

### S3 Configuration
variable "s3_bucket_name" {
  description = "Name of the S3 bucket for static assets"
  type        = string
}