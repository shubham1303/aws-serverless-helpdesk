# terraform/environments/dev/outputs.tf

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}

output "lambda_security_group_id" {
  description = "Security group ID for Lambda functions"
  value       = module.networking.lambda_security_group_id
}

# DynamoDB Outputs
output "tickets_table_name" {
  description = "Name of the tickets table"
  value       = module.dynamodb.tickets_table_name
}

output "users_table_name" {
  description = "Name of the users table"
  value       = module.dynamodb.users_table_name
}

output "comments_table_name" {
  description = "Name of the comments table"
  value       = module.dynamodb.comments_table_name
}

output "all_table_arns" {
  description = "ARNs of all DynamoDB tables"
  value       = module.dynamodb.all_table_arns
}

# Lambda Outputs
output "create_ticket_function_name" {
  description = "Name of create ticket function"
  value       = module.lambda.create_ticket_function_name
}

output "get_tickets_function_name" {
  description = "Name of get tickets function"
  value       = module.lambda.get_tickets_function_name
}

# API Gateway Outputs
output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "api_id" {
  description = "API Gateway ID"
  value       = module.api_gateway.api_id
}

# Cognito Outputs
output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = module.cognito.user_pool_client_id
}

output "cognito_domain" {
  description = "Cognito hosted UI domain"
  value       = "https://${module.cognito.user_pool_domain}.auth.us-east-1.amazoncognito.com"
}

# Frontend Hosting Outputs
output "frontend_url" {
  description = "CloudFront URL for frontend"
  value       = module.s3_cloudfront.cloudfront_url
}

output "frontend_bucket" {
  description = "S3 bucket name for frontend files"
  value       = module.s3_cloudfront.s3_bucket_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.s3_cloudfront.cloudfront_distribution_id
}