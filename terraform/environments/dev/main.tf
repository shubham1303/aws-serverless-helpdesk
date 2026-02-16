# terraform/environments/dev/main.tf
# Development environment configuration

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Backend configuration for remote state
  backend "s3" {
    bucket         = "helpdesk-tfstate-shub1303"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "helpdesk-terraform-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Data source to get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_cidr           = var.vpc_cidr
  availability_zones = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
}

# DynamoDB Module
module "dynamodb" {
  source = "../../modules/dynamodb"

  project_name                 = var.project_name
  environment                  = var.environment
  enable_point_in_time_recovery = var.enable_point_in_time_recovery
}

# Lambda Module
module "lambda" {
  source = "../../modules/lambda"

  project_name        = var.project_name
  environment         = var.environment
  tickets_table_name  = module.dynamodb.tickets_table_name
  users_table_name    = module.dynamodb.users_table_name
  comments_table_name = module.dynamodb.comments_table_name
  sla_table_name      = module.dynamodb.sla_tracking_table_name
  dynamodb_table_arns = module.dynamodb.all_table_arns
  cognito_user_pool_arn = module.cognito.user_pool_arn 
}

# Cognito Module
module "cognito" {
  source = "../../modules/cognito"

  project_name = var.project_name
  environment  = var.environment
  
  callback_urls = ["http://localhost:3000/callback", "http://localhost:3000"]
  logout_urls   = ["http://localhost:3000", "http://localhost:3000/logout"]

  post_signup_lambda_arn = module.lambda.post_signup_function_arn
}

# API Gateway Module
module "api_gateway" {
  source = "../../modules/api_gateway"

  project_name     = var.project_name
  environment      = var.environment
  
  # Lambda function names
  create_ticket_function_name  = module.lambda.create_ticket_function_name
  get_tickets_function_name    = module.lambda.get_tickets_function_name
  update_ticket_function_name  = module.lambda.update_ticket_function_name
  add_comment_function_name    = module.lambda.add_comment_function_name
  
  # Lambda invoke ARNs
  create_ticket_invoke_arn = module.lambda.create_ticket_invoke_arn
  get_tickets_invoke_arn   = module.lambda.get_tickets_invoke_arn
  update_ticket_invoke_arn = module.lambda.update_ticket_invoke_arn
  add_comment_invoke_arn   = module.lambda.add_comment_invoke_arn
  
  # Cognito 
  cognito_user_pool_arn = module.cognito.user_pool_arn
}

# S3 + CloudFront Module
module "s3_cloudfront" {
  source = "../../modules/s3_cloudfront"

  project_name = var.project_name
  environment  = var.environment
}