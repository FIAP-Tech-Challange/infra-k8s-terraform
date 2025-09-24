variable "lambda_function_name" {
  description = "Name of the main Lambda function"
  type        = string
  default     = "sahdoSimpleFunction"
}

variable "authorizer_function_name" {
  description = "Name of the authorizer Lambda function"
  type        = string
  default     = "sahdoAuthorizerFunction"
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

variable "database_port" {
  description = "Port of the database"
  type        = number
}

variable "database_host" {
  description = "Host of the database"
  type        = string
}

variable "database_user" {
  description = "User of the database"
  type        = string
}

variable "database_password" {
  description = "Password of the database"
  type        = string
  sensitive   = true
}

variable "database_name" {
  description = "Name of the database"
  type        = string
}
