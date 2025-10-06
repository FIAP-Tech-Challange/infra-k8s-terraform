terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Use existing LabRole for EKS Cluster (AWS Academy compatible)
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Use LabRole for nodes as well (AWS Academy limitation)
# Note: LabRole typically has all necessary policies attached

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = "eks-${var.project_name}"
  version  = var.cluster_version
  role_arn = data.aws_iam_role.lab_role.arn

  access_config {
    authentication_mode                         = "CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = ["0.0.0.0/0"]
  }

  depends_on = [
    data.aws_iam_role.lab_role,
  ]
  
  tags = merge(var.tags, {
    Name = "eks-${var.project_name}"
  })
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = "nodeg-${var.project_name}"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = var.subnet_ids
  
  # AMI and instance configuration
  ami_type        = "AL2_x86_64"
  capacity_type   = "ON_DEMAND"
  disk_size       = var.node_disk_size
  instance_types  = [var.instance_type]

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable_percentage = 25
  }

  # Node group labels
  labels = {
    "node-group" = "nodeg-${var.project_name}"
    "Environment" = "development"
  }

  # Force dependency on cluster being ready
  depends_on = [
    data.aws_iam_role.lab_role,
    aws_eks_cluster.cluster,
  ]
  
  tags = merge(var.tags, {
    Name = "nodeg-${var.project_name}"
  })
}

# ConfigMap aws-auth will be configured via GitHub Actions workflow
# No need for access entries when using CONFIG_MAP authentication mode
