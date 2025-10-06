output "ecr_repository_url" {
    description = "ECR Repo URL"
    value       = aws_ecr_repository.app_repo.repository_url
}
