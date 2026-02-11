# terraform/modules/api_gateway/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "create_ticket_function_name" {
  description = "Name of create ticket Lambda function"
  type        = string
}

variable "create_ticket_invoke_arn" {
  description = "Invoke ARN of create ticket Lambda function"
  type        = string
}

variable "get_tickets_function_name" {
  description = "Name of get tickets Lambda function"
  type        = string
}

variable "get_tickets_invoke_arn" {
  description = "Invoke ARN of get tickets Lambda function"
  type        = string
}

variable "update_ticket_function_name" {
  description = "Name of update ticket Lambda function"
  type        = string
}

variable "update_ticket_invoke_arn" {
  description = "Invoke ARN of update ticket Lambda function"
  type        = string
}

variable "add_comment_function_name" {
  description = "Name of add comment Lambda function"
  type        = string
}

variable "add_comment_invoke_arn" {
  description = "Invoke ARN of add comment Lambda function"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "ARN of Cognito User Pool for authorization"
  type        = string
}