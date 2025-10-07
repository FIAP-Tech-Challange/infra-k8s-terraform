# Gateway Module
module "gateway" {
  source                   = "./modules/gateway"
  lambda_function_name     = var.lambda_function_name
  authorizer_function_name = var.authorizer_function_name
  database_port            = var.database_port
  database_user            = var.database_user
  database_host            = var.database_host
  database_name            = var.database_name
  database_password        = var.database_password
  authorizer_key           = var.authorizer_key
}

#EKS Module

# Data source for default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

module "eks" {
  source = "./modules/eks"

  project_name            = var.project_name
  cluster_version         = var.cluster_version
  vpc_id                  = data.aws_vpc.default.id
  subnet_ids              = data.aws_subnets.default.ids
  instance_type           = var.instance_type
  node_group_desired_size = var.node_group_desired_size
  node_group_max_size     = var.node_group_max_size
  node_group_min_size     = var.node_group_min_size
  node_disk_size          = var.node_disk_size
  tags                    = var.tags
}

module "ecr" {
  source = "./modules/ecr"
}
