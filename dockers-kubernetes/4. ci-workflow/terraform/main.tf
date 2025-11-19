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

# IAM Role for Elastic Beanstalk
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
  description = "React Docker application"
}

# Elastic Beanstalk Environment
resource "aws_elastic_beanstalk_environment" "app_env" {
  name                = "${var.app_name}-${var.environment}"
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

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = "false"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = "7"
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
