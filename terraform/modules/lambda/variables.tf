# terraform/modules/lambda/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tickets_table_name" {
  description = "Name of the tickets DynamoDB table"
  type        = string
}

variable "users_table_name" {
  description = "Name of the users DynamoDB table"
  type        = string
}

variable "comments_table_name" {
  description = "Name of the comments DynamoDB table"
  type        = string
}

variable "sla_table_name" {
  description = "Name of the SLA tracking DynamoDB table"
  type        = string
}

variable "dynamodb_table_arns" {
  description = "List of DynamoDB table ARNs for IAM permissions"
  type        = list(string)
}