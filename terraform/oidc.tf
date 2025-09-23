# ========== OIDC Provider ==========
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# ========== S3 Bucket for Deployment ==========
resource "aws_s3_bucket" "cicd_deploy_bucket" {
  bucket = "${var.bucket_prefix}-cicd-deploy-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "cicd_deploy_bucket" {
  bucket = aws_s3_bucket.cicd_deploy_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# ========== IAM Role for GitHub Actions ==========
resource "aws_iam_role" "github_actions_role" {
  name = "github-actions-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # Replace with your actual GitHub repo
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_repo}:ref:refs/heads/main",
            ]
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name = "GitHub Actions OIDC Role"
    Purpose = "CICD Pipeline"
  }
}

# ========== IAM Policy for S3 Deployment ==========
resource "aws_iam_policy" "s3_deploy" {
  name        = "github-actions-s3-deploy-policy"
  description = "Allow GitHub Actions to deploy to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.cicd_deploy_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.cicd_deploy_bucket.arn
        ]
      }
    ]
  })
}

# ========== Attach S3 policy to role ==========
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.s3_deploy.arn
}
