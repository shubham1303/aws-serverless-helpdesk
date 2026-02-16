# terraform/modules/cognito/variables.tf

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "callback_urls" {
  description = "List of allowed callback URLs for OAuth"
  type        = list(string)
  default     = ["http://localhost:3000/callback", "http://localhost:3000"]
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
  default     = ["http://localhost:3000", "http://localhost:3000/logout"]
}

variable "post_signup_lambda_arn" {
  description = "ARN of post-signup Lambda trigger"
  type        = string
  default     = ""
}