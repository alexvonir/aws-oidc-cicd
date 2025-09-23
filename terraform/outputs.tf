# ========== Outputs ==========
output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions OIDC role"
  value       = aws_iam_role.github_actions_role.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 deployment bucket"
  value       = aws_s3_bucket.cicd_deploy_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 deployment bucket"
  value       = aws_s3_bucket.cicd_deploy_bucket.arn
}

output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = aws_iam_openid_connect_provider.github.arn
}
