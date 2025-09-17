terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "gateway" {
  source = "./gateway"
  lambda_function_name     = var.lambda_function_name
  authorizer_function_name = var.authorizer_function_name
}

output "api_hello_auth_endpoint" {
  description = "URL for the authenticated hello endpoint"
  value       = module.gateway.api_hello_auth
}
