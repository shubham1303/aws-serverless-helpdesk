# terraform/modules/dynamodb/main.tf
# DynamoDB tables for helpdesk platform

# Tickets Table - Stores all support tickets
resource "aws_dynamodb_table" "tickets" {
  name           = "${var.project_name}-${var.environment}-tickets"
  billing_mode   = "PAY_PER_REQUEST" # Serverless pricing
  hash_key       = "ticket_id"
  range_key      = "created_at"

  attribute {
    name = "ticket_id"
    type = "S" # String
  }

  attribute {
    name = "created_at"
    type = "S" # ISO 8601 timestamp
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "assigned_to"
    type = "S"
  }

  # Global Secondary Index - Query tickets by user
  global_secondary_index {
    name            = "UserIndex"
    hash_key        = "user_id"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # Global Secondary Index - Query tickets by status
  global_secondary_index {
    name            = "StatusIndex"
    hash_key        = "status"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # Global Secondary Index - Query tickets by assigned agent
  global_secondary_index {
    name            = "AssignedIndex"
    hash_key        = "assigned_to"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # Point-in-time recovery for data protection
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Server-side encryption
  server_side_encryption {
    enabled = true
  }

  # TTL for automatic cleanup (optional)
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tickets"
    Environment = var.environment
  }
}

# Users Table - Stores customer and agent information
resource "aws_dynamodb_table" "users" {
  name         = "${var.project_name}-${var.environment}-users"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "user_type"
    type = "S" # customer, agent, admin
  }

  # Global Secondary Index - Query by email
  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "email"
    projection_type = "ALL"
  }

  # Global Secondary Index - Query by user type
  global_secondary_index {
    name            = "UserTypeIndex"
    hash_key        = "user_type"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-users"
    Environment = var.environment
  }
}

# Comments Table - Stores ticket comments/replies
resource "aws_dynamodb_table" "comments" {
  name         = "${var.project_name}-${var.environment}-comments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticket_id"
  range_key    = "comment_id"

  attribute {
    name = "ticket_id"
    type = "S"
  }

  attribute {
    name = "comment_id"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  # Local Secondary Index - Query comments by timestamp
  local_secondary_index {
    name            = "TimeIndex"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-comments"
    Environment = var.environment
  }
}

# SLA Tracking Table - Monitors service level agreements
resource "aws_dynamodb_table" "sla_tracking" {
  name         = "${var.project_name}-${var.environment}-sla-tracking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ticket_id"

  attribute {
    name = "ticket_id"
    type = "S"
  }

  attribute {
    name = "priority"
    type = "S" # low, medium, high, critical
  }

  attribute {
    name = "breach_time"
    type = "N" # Unix timestamp
  }

  # Global Secondary Index - Query by priority
  global_secondary_index {
    name            = "PriorityIndex"
    hash_key        = "priority"
    range_key       = "breach_time"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-sla-tracking"
    Environment = var.environment
  }
}

# Attachments Metadata Table - Stores file attachment metadata
resource "aws_dynamodb_table" "attachments" {
  name         = "${var.project_name}-${var.environment}-attachments"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "attachment_id"

  attribute {
    name = "attachment_id"
    type = "S"
  }

  attribute {
    name = "ticket_id"
    type = "S"
  }

  # Global Secondary Index - Query attachments by ticket
  global_secondary_index {
    name            = "TicketIndex"
    hash_key        = "ticket_id"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-attachments"
    Environment = var.environment
  }
}

# Analytics Table - Stores aggregated metrics
resource "aws_dynamodb_table" "analytics" {
  name         = "${var.project_name}-${var.environment}-analytics"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "metric_type"
  range_key    = "timestamp"

  attribute {
    name = "metric_type"
    type = "S" # daily_tickets, resolution_time, etc.
  }

  attribute {
    name = "timestamp"
    type = "S" # Date in ISO format
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  server_side_encryption {
    enabled = true
  }

  ttl {
    attribute_name = "ttl"
    enabled        = true
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-analytics"
    Environment = var.environment
  }
}