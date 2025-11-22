variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "multi-docker"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "production"
}

variable "solution_stack_name" {
  description = "Elastic Beanstalk solution stack name for Docker Compose"
  type        = string
  default     = "64bit Amazon Linux 2023 v4.8.0 running Docker"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "min_instance_count" {
  description = "Minimum number of instances in autoscaling group"
  type        = string
  default     = "1"
}

variable "max_instance_count" {
  description = "Maximum number of instances in autoscaling group"
  type        = string
  default     = "4"
}

variable "environment_type" {
  description = "Environment type (LoadBalanced or SingleInstance)"
  type        = string
  default     = "SingleInstance"
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  default     = "postgrespassword"
  sensitive   = true
}
