terraform {
  backend "http" {
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
}

# Configure AWS region and Assume Role 
provider "aws" {
  region = var.aws_region
  assume_role {
    role_arn = var.aws_assume_role
  }
}

# Application setup
locals {
  app_name          = "appname-${var.stage}-${var.aws_region}"
  app_domain_name   = "service-name.company-name.com"
  app_port          = 8080
  app_count         = "1"
}

/* -------------------------------------------------------------------------- */
/*                                   Modules                                  */
/* -------------------------------------------------------------------------- */
# ECR
module "ecr" {
  source = "./ecr"

  app_name    = local.app_name

  tags = var.tags
}

# VPC for ECS Fargate
module "vpc" {
  source = "./vpc"

  app_name = local.app_name

  stage                     = var.stage
  app_port                  = local.app_port
  availability_zones        = var.availability_zones
  region                    = var.aws_region
  tags = var.tags
}

# ECS task definition and service
module "ecs" {
  source = "./ecs"

  # Task definition
  app_name           = local.app_name
  app_image      = var.app_image
  fargate_cpu    = 1024
  fargate_memory = 2048
  app_port       = local.app_port
  vpc_id         = module.vpc.vpc_id

  # Task environment variables
  stage             = var.stage
  aws_region        = var.aws_region

  # Service
  app_count                       = local.app_count
  aws_security_group_ecs_tasks_id = module.vpc.ecs_tasks_security_group_id
  private_subnet_ids              = module.vpc.private_subnet_ids

  tags = var.tags
}

# API Gateway and VPC links
module "api_gateway" {
  source = "./api-gateway"

  name                   = local.app_name
  integration_input_type = "HTTP_PROXY"
  path_part              = "{proxy+}"
  app_port               = local.app_port
  nlb_dns_name           = module.ecs.nlb_dns_name
  nlb_arn                = module.ecs.nlb_arn
  stage                  = var.stage
  domain_name            = "${var.aws_region}.${var.stage}.${local.app_domain_name}"
  certificate_arn         = var.acm_certificate_arn
  zone_id                = var.hosted_zone_id
  aws_region             = var.aws_region

  tags = var.tags
}

# DynamoDB
module "dynamo" {
  source = "./dynamo"

  table_name = "user_table"

  tags = var.tags
}
