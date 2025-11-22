terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets in specific availability zones that support t3.small
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

# Custom Security Group
resource "aws_security_group" "multi_docker" {
  name        = "multi-docker"
  description = "Security group for multi-docker application"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow PostgreSQL and Redis traffic within security group"
    from_port   = 5432
    to_port     = 6379
    protocol    = "tcp"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "multi-docker"
    ManagedBy = "Terraform"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "postgres" {
  name       = "multi-docker-postgres-subnet"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name      = "multi-docker-postgres-subnet"
    ManagedBy = "Terraform"
  }

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

# RDS PostgreSQL Database
resource "aws_db_instance" "postgres" {
  identifier             = "multi-docker-postgres"
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "fibvalues"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.multi_docker.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  tags = {
    Name      = "multi-docker-postgres"
    ManagedBy = "Terraform"
  }
}

# ElastiCache Subnet Group
resource "aws_elasticache_subnet_group" "redis" {
  name       = "redis-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name      = "redis-subnet-group"
    ManagedBy = "Terraform"
  }

  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

# ElastiCache Redis Cluster
resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "multi-docker-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis7"
  port                 = 6379
  security_group_ids   = [aws_security_group.multi_docker.id]
  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  transit_encryption_enabled = false

  tags = {
    Name      = "multi-docker-redis"
    ManagedBy = "Terraform"
  }
}

# IAM Role for Elastic Beanstalk EC2 instances
resource "aws_iam_role" "elasticbeanstalk_ec2_role" {
  name = "${var.app_name}-eb-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_web_tier" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_worker_tier" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_multicontainer_docker" {
  role       = aws_iam_role.elasticbeanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
}

resource "aws_iam_instance_profile" "elasticbeanstalk_ec2_profile" {
  name = "${var.app_name}-eb-ec2-profile"
  role = aws_iam_role.elasticbeanstalk_ec2_role.name
}

# IAM Role for Elastic Beanstalk Service
resource "aws_iam_role" "elasticbeanstalk_service_role" {
  name = "${var.app_name}-eb-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_service" {
  role       = aws_iam_role.elasticbeanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "elasticbeanstalk_service_managed" {
  role       = aws_iam_role.elasticbeanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

# Elastic Beanstalk Application
resource "aws_elastic_beanstalk_application" "app" {
  name        = var.app_name
  description = "Multi-container Docker application with React, Express, Redis, and PostgreSQL"
}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "app_env" {
  name                = "${var.app_name}-env"
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.solution_stack_name

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.elasticbeanstalk_ec2_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.elasticbeanstalk_service_role.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnets.default.ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.multi_docker.id
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.min_instance_count
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.max_instance_count
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = var.environment_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "Port"
    value     = "80"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  # Environment Variables
  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_HOST"
    value     = aws_elasticache_cluster.redis.cache_nodes[0].address
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "REDIS_PORT"
    value     = "6379"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PGUSER"
    value     = var.db_username
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PGPASSWORD"
    value     = var.db_password
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PGHOST"
    value     = aws_db_instance.postgres.address
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PGDATABASE"
    value     = aws_db_instance.postgres.db_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "PGPORT"
    value     = "5432"
  }

  tags = {
    Name        = "${var.app_name}-env"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  depends_on = [
    aws_db_instance.postgres,
    aws_elasticache_cluster.redis
  ]
}
