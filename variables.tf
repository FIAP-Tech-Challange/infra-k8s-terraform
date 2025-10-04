# Project Configuration
variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "tc-3-f106"
}

variable "region_default" {
  description = "The default region for the resources"
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default = {
    name = "tc_tf"
  }
}

variable "lambda_function_name" {
  description = "Name of the main Lambda function"
  type        = string
}

variable "authorizer_function_name" {
  description = "Name of the authorizer Lambda function"
  type        = string
}

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
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

# EKS Configuration
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.31"
}

variable "instance_type" {
  description = "The instance type for the EKS worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
}