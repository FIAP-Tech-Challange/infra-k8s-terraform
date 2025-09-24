terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    key = "terraform/terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region
}

module "gateway" {
  source = "./gateway"
  lambda_function_name     = var.lambda_function_name
  authorizer_function_name = var.authorizer_function_name
  database_port            = var.database_port
  database_user            = var.database_user
  database_host            = var.database_host
  database_name            = var.database_name
  database_password        = var.database_password
}

output "api_hello_auth_endpoint" {
  description = "URL for the authenticated hello endpoint"
  value       = module.gateway.api_hello_auth
}
