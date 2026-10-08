# terraform/modules/api_gateway/main.tf
# API Gateway for helpdesk platform

# REST API
resource "aws_api_gateway_rest_api" "helpdesk_api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "Helpdesk Platform REST API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-api"
    Environment = var.environment
  }
}

# Cognito Authorizer
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "${var.project_name}-${var.environment}-cognito-authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  provider_arns = [var.cognito_user_pool_arn]
}

# /tickets resource
resource "aws_api_gateway_resource" "tickets" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  parent_id   = aws_api_gateway_rest_api.helpdesk_api.root_resource_id
  path_part   = "tickets"
}

# /tickets/{id} resource
resource "aws_api_gateway_resource" "ticket_id" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  parent_id   = aws_api_gateway_resource.tickets.id
  path_part   = "{id}"
}

# /tickets/{id}/comments resource
resource "aws_api_gateway_resource" "comments" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  parent_id   = aws_api_gateway_resource.ticket_id.id
  path_part   = "comments"
}

# POST /tickets - Create Ticket
resource "aws_api_gateway_method" "create_ticket" {
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id   = aws_api_gateway_resource.tickets.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "create_ticket" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.tickets.id
  http_method = aws_api_gateway_method.create_ticket.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.create_ticket_invoke_arn
}

# GET /tickets - List Tickets
resource "aws_api_gateway_method" "get_tickets" {
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id   = aws_api_gateway_resource.tickets.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_tickets" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.tickets.id
  http_method = aws_api_gateway_method.get_tickets.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_tickets_invoke_arn
}

# GET /tickets/{id} - Get Single Ticket
resource "aws_api_gateway_method" "get_ticket_by_id" {
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id   = aws_api_gateway_resource.ticket_id.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "get_ticket_by_id" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.ticket_id.id
  http_method = aws_api_gateway_method.get_ticket_by_id.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.get_tickets_invoke_arn
}

# PUT /tickets/{id} - Update Ticket
resource "aws_api_gateway_method" "update_ticket" {
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id   = aws_api_gateway_resource.ticket_id.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "update_ticket" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.ticket_id.id
  http_method = aws_api_gateway_method.update_ticket.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.update_ticket_invoke_arn
}

# POST /tickets/{id}/comments - Add Comment
resource "aws_api_gateway_method" "add_comment" {
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id   = aws_api_gateway_resource.comments.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "add_comment" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.comments.id
  http_method = aws_api_gateway_method.add_comment.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.add_comment_invoke_arn
}

# CORS Configuration (Allow frontend to call API)

# OPTIONS /tickets
resource "aws_api_gateway_method" "tickets_options" {
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id   = aws_api_gateway_resource.tickets.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "tickets_options" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.tickets.id
  http_method = aws_api_gateway_method.tickets_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "tickets_options" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.tickets.id
  http_method = aws_api_gateway_method.tickets_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "tickets_options" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id
  resource_id = aws_api_gateway_resource.tickets.id
  http_method = aws_api_gateway_method.tickets_options.http_method
  status_code = aws_api_gateway_method_response.tickets_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Deployment and Stage
resource "aws_api_gateway_deployment" "helpdesk_deployment" {
  rest_api_id = aws_api_gateway_rest_api.helpdesk_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.tickets.id,
      aws_api_gateway_resource.ticket_id.id,
      aws_api_gateway_resource.comments.id,
      aws_api_gateway_method.create_ticket.id,
      aws_api_gateway_method.get_tickets.id,
      aws_api_gateway_method.update_ticket.id,
      aws_api_gateway_method.add_comment.id,
      aws_api_gateway_integration.create_ticket.id,
      aws_api_gateway_integration.get_tickets.id,
      aws_api_gateway_integration.update_ticket.id,
      aws_api_gateway_integration.add_comment.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "helpdesk_stage" {
  deployment_id = aws_api_gateway_deployment.helpdesk_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.helpdesk_api.id
  stage_name    = var.environment

  tags = {
    Name        = "${var.project_name}-${var.environment}-stage"
    Environment = var.environment
  }
}

# Lambda Permissions (Allow API Gateway to invoke Lambda)
resource "aws_lambda_permission" "create_ticket" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.create_ticket_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.helpdesk_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_tickets" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.get_tickets_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.helpdesk_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "update_ticket" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.update_ticket_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.helpdesk_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "add_comment" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.add_comment_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.helpdesk_api.execution_arn}/*/*"
}

# CloudWatch Logs for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project_name}-${var.environment}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}