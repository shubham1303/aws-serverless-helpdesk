# terraform/modules/cognito/main.tf
# Cognito User Pool for authentication

# User Pool - The main user directory
resource "aws_cognito_user_pool" "helpdesk_pool" {
  name = "${var.project_name}-${var.environment}-user-pool"

  # Username configuration
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = false
    temporary_password_validity_days = 7
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # User attributes schema
  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "name"
    attribute_data_type = "String"
    required            = true
    mutable             = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Custom attribute for user type
  schema {
    name                = "user_type"
    attribute_data_type = "String"
    mutable             = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 20
    }
  }

# Lambda trigger to auto-assign users to customers group
  lambda_config {
    post_confirmation = var.post_signup_lambda_arn
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-user-pool"
    Environment = var.environment
  }
}

# User Pool Client - For frontend applications
resource "aws_cognito_user_pool_client" "helpdesk_client" {
  name         = "${var.project_name}-${var.environment}-client"
  user_pool_id = aws_cognito_user_pool.helpdesk_pool.id

  # OAuth configuration
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls

  # Supported identity providers
  supported_identity_providers = ["COGNITO"]

  # Token validity
  id_token_validity     = 60  # 60 minutes
  access_token_validity = 60  # 60 minutes
  refresh_token_validity = 30 # 30 days

  token_validity_units {
    id_token      = "minutes"
    access_token  = "minutes"
    refresh_token = "days"
  }

  # Explicit auth flows
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  # Prevent user existence errors
  prevent_user_existence_errors = "ENABLED"

  # Read and write attributes
  read_attributes = [
    "email",
    "email_verified",
    "name",
    "custom:user_type"
  ]

  write_attributes = [
    "email",
    "name",
    "custom:user_type"
  ]
}

# User Pool Domain - For hosted UI
resource "aws_cognito_user_pool_domain" "helpdesk_domain" {
  domain       = "${var.project_name}-${var.environment}-${random_string.domain_suffix.result}"
  user_pool_id = aws_cognito_user_pool.helpdesk_pool.id
}

# Random string for unique domain name
resource "random_string" "domain_suffix" {
  length  = 8
  special = false
  upper   = false
}

# User Groups - For role-based access control

# Customers Group
resource "aws_cognito_user_group" "customers" {
  name         = "customers"
  user_pool_id = aws_cognito_user_pool.helpdesk_pool.id
  description  = "Regular customers who can create and view their own tickets"
  precedence   = 3
}

# Agents Group
resource "aws_cognito_user_group" "agents" {
  name         = "agents"
  user_pool_id = aws_cognito_user_pool.helpdesk_pool.id
  description  = "Support agents who can manage tickets"
  precedence   = 2
}

# Admins Group
resource "aws_cognito_user_group" "admins" {
  name         = "admins"
  user_pool_id = aws_cognito_user_pool.helpdesk_pool.id
  description  = "Administrators with full access"
  precedence   = 1
}

# Identity Pool (for AWS credentials - optional for future use)
resource "aws_cognito_identity_pool" "helpdesk_identity" {
  identity_pool_name               = "${var.project_name}_${var.environment}_identity"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.helpdesk_client.id
    provider_name           = aws_cognito_user_pool.helpdesk_pool.endpoint
    server_side_token_check = false
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-identity-pool"
    Environment = var.environment
  }
}