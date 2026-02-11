# terraform/modules/api_gateway/outputs.tf

output "api_id" {
  description = "ID of the API Gateway REST API"
  value       = aws_api_gateway_rest_api.helpdesk_api.id
}

output "api_endpoint" {
  description = "Full API endpoint URL"
  value       = "${aws_api_gateway_stage.helpdesk_stage.invoke_url}"
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = aws_api_gateway_rest_api.helpdesk_api.arn
}

output "stage_name" {
  description = "Name of the deployment stage"
  value       = aws_api_gateway_stage.helpdesk_stage.stage_name
}