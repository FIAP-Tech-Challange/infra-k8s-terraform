# output "validate_cpf_endpoint" {
#   description = "URL for the validate CPF endpoint"
#   value       = module.gateway.api_validate_cpf
# }

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
