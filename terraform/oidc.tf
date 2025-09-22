# 1) Create OIDC provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
url = "https://token.actions.githubusercontent.com"
client_id_list = ["sts.amazonaws.com"]
# thumbprint_list: leave to your tooling or supply current thumbprint; some modules auto-handle it
thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}


# 2) IAM role that GitHub Actions can assume via OIDC
resource "aws_iam_role" "github_actions_role" {
name = "github-actions-oidc-role"


assume_role_policy = jsonencode({
Version = "2012-10-17",
Statement = [
{
Effect = "Allow",
Principal = {
Federated = aws_iam_openid_connect_provider.github.arn
},
Action = "sts:AssumeRoleWithWebIdentity",
Condition = {
StringLike = {
"token.actions.githubusercontent.com:sub" : "repo:${var.github_repo}:ref:refs/heads/main"
},
StringEquals = {
"token.actions.githubusercontent.com:aud" : var.github_audience
}
}
}
]
})
}


# 3) Attach a policy — example: limited S3 deploy
resource "aws_iam_policy" "s3_deploy" {
name = "github-actions-s3-deploy-policy"
policy = jsonencode({
Version = "2012-10-17",
Statement = [
{
Effect = "Allow",
Action = ["s3:PutObject","s3:PutObjectAcl","s3:ListBucket"],
Resource = [
"arn:aws:s3:::cicd-deploy-bucket",
"arn:aws:s3:::cicd-deploy-bucket/*"
]
}
]
})
}


resource "aws_iam_role_policy_attachment" "attach" {
role = aws_iam_role.github_actions_role.name
policy_arn = aws_iam_policy.s3_deploy.arn
}
