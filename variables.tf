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