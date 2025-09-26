terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
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
  source = "./modules/gateway"
  lambda_function_name     = var.lambda_function_name
  authorizer_function_name = var.authorizer_function_name
  database_port            = var.database_port
  database_user            = var.database_user
  database_host            = var.database_host
  database_name            = var.database_name
  database_password        = var.database_password
}

module "network" {
  source = "./modules/network"
  
  project_name       = var.project_name
  region            = var.region_default
  cidr_block        = var.cidr_block
  availability_zones = var.availability_zones
  tags              = var.tags
}

module "eks" {
  source = "./modules/eks"
  
  project_name            = var.project_name
  cluster_version         = var.cluster_version
  vpc_id                  = module.network.vpc_id
  subnet_ids              = module.network.public_subnet_ids
  security_group_ids      = [module.network.security_group_id]
  instance_type           = var.instance_type
  node_group_desired_size = var.node_group_desired_size
  node_group_max_size     = var.node_group_max_size
  node_group_min_size     = var.node_group_min_size
  node_disk_size          = var.node_disk_size
  principal_user_arn      = data.aws_iam_user.principal_user.arn
  tags                    = var.tags
}

output "api_hello_auth_endpoint" {
  description = "URL for the authenticated hello endpoint"
  value       = module.gateway.api_hello_auth
}

# Network Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.network.vpc_cidr_block
}

output "subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "security_group_id" {
  description = "ID of the default security group"
  value       = module.network.security_group_id
}

# EKS Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the cluster control plane"
  value       = module.eks.cluster_security_group_id
}