variable "aws_region" { 
  default = "us-east-1" 
}

variable "github_repo" { 
  description = "GitHub repository in format: owner/repo-name"
  type        = string
}

variable "github_audience" { 
  default = "sts.amazonaws.com" 
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket name to ensure uniqueness"
  type        = string
  default     = "alexvonir"  # Replace with your initials or company name
}
