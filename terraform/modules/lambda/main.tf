# terraform/modules/lambda/main.tf
# Lambda functions for helpdesk platform

# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-role"
    Environment = var.environment
  }
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "${var.project_name}-${var.environment}-lambda-dynamodb-policy"
  description = "Allows Lambda to access DynamoDB tables"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = var.dynamodb_table_arns
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [for arn in var.dynamodb_table_arns : "${arn}/index/*"]
      }
    ]
  })
}

# Attach DynamoDB policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

# Attach AWS managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function: Create Ticket
resource "aws_lambda_function" "create_ticket" {
  filename         = data.archive_file.create_ticket.output_path
  function_name    = "${var.project_name}-${var.environment}-create-ticket"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.create_ticket.output_base64sha256
  runtime         = "python3.12"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      TICKETS_TABLE = var.tickets_table_name
      SLA_TABLE     = var.sla_table_name
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-create-ticket"
    Environment = var.environment
  }
}

# Lambda function: Get Tickets
resource "aws_lambda_function" "get_tickets" {
  filename         = data.archive_file.get_tickets.output_path
  function_name    = "${var.project_name}-${var.environment}-get-tickets"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.get_tickets.output_base64sha256
  runtime         = "python3.12"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      TICKETS_TABLE = var.tickets_table_name
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-get-tickets"
    Environment = var.environment
  }
}

# Lambda function: Update Ticket
resource "aws_lambda_function" "update_ticket" {
  filename         = data.archive_file.update_ticket.output_path
  function_name    = "${var.project_name}-${var.environment}-update-ticket"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.update_ticket.output_base64sha256
  runtime         = "python3.12"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      TICKETS_TABLE = var.tickets_table_name
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-update-ticket"
    Environment = var.environment
  }
}

# Lambda function: Add Comment
resource "aws_lambda_function" "add_comment" {
  filename         = data.archive_file.add_comment.output_path
  function_name    = "${var.project_name}-${var.environment}-add-comment"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.add_comment.output_base64sha256
  runtime         = "python3.12"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      COMMENTS_TABLE = var.comments_table_name
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-add-comment"
    Environment = var.environment
  }
}

# CloudWatch Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "create_ticket" {
  name              = "/aws/lambda/${aws_lambda_function.create_ticket.function_name}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "get_tickets" {
  name              = "/aws/lambda/${aws_lambda_function.get_tickets.function_name}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "update_ticket" {
  name              = "/aws/lambda/${aws_lambda_function.update_ticket.function_name}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "add_comment" {
  name              = "/aws/lambda/${aws_lambda_function.add_comment.function_name}"
  retention_in_days = 7

  tags = {
    Environment = var.environment
  }
}

# Data sources to zip Lambda code
data "archive_file" "create_ticket" {
  type        = "zip"
  source_file = "${path.module}/../../../backend/lambdas/create_ticket/lambda_function.py"
  output_path = "${path.module}/lambda_packages/create_ticket.zip"
}

data "archive_file" "get_tickets" {
  type        = "zip"
  source_file = "${path.module}/../../../backend/lambdas/get_tickets/lambda_function.py"
  output_path = "${path.module}/lambda_packages/get_tickets.zip"
}

data "archive_file" "update_ticket" {
  type        = "zip"
  source_file = "${path.module}/../../../backend/lambdas/update_ticket/lambda_function.py"
  output_path = "${path.module}/lambda_packages/update_ticket.zip"
}

data "archive_file" "add_comment" {
  type        = "zip"
  source_file = "${path.module}/../../../backend/lambdas/add_comment/lambda_function.py"
  output_path = "${path.module}/lambda_packages/add_comment.zip"
}