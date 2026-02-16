# terraform/modules/lambda/outputs.tf

output "create_ticket_function_arn" {
  description = "ARN of create ticket Lambda function"
  value       = aws_lambda_function.create_ticket.arn
}

output "create_ticket_function_name" {
  description = "Name of create ticket Lambda function"
  value       = aws_lambda_function.create_ticket.function_name
}

output "create_ticket_invoke_arn" {
  description = "Invoke ARN of create ticket Lambda function"
  value       = aws_lambda_function.create_ticket.invoke_arn
}

output "get_tickets_function_arn" {
  description = "ARN of get tickets Lambda function"
  value       = aws_lambda_function.get_tickets.arn
}

output "get_tickets_function_name" {
  description = "Name of get tickets Lambda function"
  value       = aws_lambda_function.get_tickets.function_name
}

output "get_tickets_invoke_arn" {
  description = "Invoke ARN of get tickets Lambda function"
  value       = aws_lambda_function.get_tickets.invoke_arn
}

output "update_ticket_function_arn" {
  description = "ARN of update ticket Lambda function"
  value       = aws_lambda_function.update_ticket.arn
}

output "update_ticket_function_name" {
  description = "Name of update ticket Lambda function"
  value       = aws_lambda_function.update_ticket.function_name
}

output "update_ticket_invoke_arn" {
  description = "Invoke ARN of update ticket Lambda function"
  value       = aws_lambda_function.update_ticket.invoke_arn
}

output "add_comment_function_arn" {
  description = "ARN of add comment Lambda function"
  value       = aws_lambda_function.add_comment.arn
}

output "add_comment_function_name" {
  description = "Name of add comment Lambda function"
  value       = aws_lambda_function.add_comment.function_name
}

output "add_comment_invoke_arn" {
  description = "Invoke ARN of add comment Lambda function"
  value       = aws_lambda_function.add_comment.invoke_arn
}

output "lambda_role_arn" {
  description = "ARN of Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}

output "post_signup_function_arn" {
  description = "ARN of post signup Lambda function"
  value       = aws_lambda_function.post_signup.arn
}