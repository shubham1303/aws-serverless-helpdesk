# terraform/bootstrap/variables.tf
# Variables for the bootstrap infrastructure

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state (must be globally unique)"
  type        = string
  # S3 bucket names must be globally unique across ALL AWS accounts
  # Format: helpdesk-tfstate-{your-initials}-{random-string}
  # Example: helpdesk-tfstate-js-a1b2c3
}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for state locking"
  type        = string
  default     = "helpdesk-terraform-locks"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "helpdesk-platform"
}