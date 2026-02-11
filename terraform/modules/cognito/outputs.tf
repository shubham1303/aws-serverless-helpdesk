# terraform/modules/cognito/outputs.tf

output "user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.helpdesk_pool.id
}

output "user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.helpdesk_pool.arn
}

output "user_pool_endpoint" {
  description = "Endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.helpdesk_pool.endpoint
}

output "user_pool_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.helpdesk_client.id
}

output "user_pool_client_secret" {
  description = "Secret of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.helpdesk_client.client_secret
  sensitive   = true
}

output "user_pool_domain" {
  description = "Domain of the Cognito User Pool"
  value       = aws_cognito_user_pool_domain.helpdesk_domain.domain
}

output "identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.helpdesk_identity.id
}

output "customers_group_name" {
  description = "Name of the customers group"
  value       = aws_cognito_user_group.customers.name
}

output "agents_group_name" {
  description = "Name of the agents group"
  value       = aws_cognito_user_group.agents.name
}

output "admins_group_name" {
  description = "Name of the admins group"
  value       = aws_cognito_user_group.admins.name
}