# terraform/modules/dynamodb/outputs.tf

output "tickets_table_name" {
  description = "Name of the tickets table"
  value       = aws_dynamodb_table.tickets.name
}

output "tickets_table_arn" {
  description = "ARN of the tickets table"
  value       = aws_dynamodb_table.tickets.arn
}

output "users_table_name" {
  description = "Name of the users table"
  value       = aws_dynamodb_table.users.name
}

output "users_table_arn" {
  description = "ARN of the users table"
  value       = aws_dynamodb_table.users.arn
}

output "comments_table_name" {
  description = "Name of the comments table"
  value       = aws_dynamodb_table.comments.name
}

output "comments_table_arn" {
  description = "ARN of the comments table"
  value       = aws_dynamodb_table.comments.arn
}

output "sla_tracking_table_name" {
  description = "Name of the SLA tracking table"
  value       = aws_dynamodb_table.sla_tracking.name
}

output "sla_tracking_table_arn" {
  description = "ARN of the SLA tracking table"
  value       = aws_dynamodb_table.sla_tracking.arn
}

output "attachments_table_name" {
  description = "Name of the attachments table"
  value       = aws_dynamodb_table.attachments.name
}

output "attachments_table_arn" {
  description = "ARN of the attachments table"
  value       = aws_dynamodb_table.attachments.arn
}

output "analytics_table_name" {
  description = "Name of the analytics table"
  value       = aws_dynamodb_table.analytics.name
}

output "analytics_table_arn" {
  description = "ARN of the analytics table"
  value       = aws_dynamodb_table.analytics.arn
}

output "all_table_arns" {
  description = "List of all table ARNs"
  value = [
    aws_dynamodb_table.tickets.arn,
    aws_dynamodb_table.users.arn,
    aws_dynamodb_table.comments.arn,
    aws_dynamodb_table.sla_tracking.arn,
    aws_dynamodb_table.attachments.arn,
    aws_dynamodb_table.analytics.arn
  ]
}