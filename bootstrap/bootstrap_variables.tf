variable "aws_region" {
  description = "AWS region for the S3 state bucket."
  type        = string
  default     = "eu-north-1" // your region
}

variable "state_bucket_name" {
  description = "The name for the S3 bucket that will store Terraform state."
  type        = string
  default     = "mybucketterraformname0" // you use it in your Main.tf Backend block
}
variable "github_org_or_username" {
  description = "Your GitHub organization or username."
  type        = string
  default     = "Val-d-emar"
}

variable "github_repository_name" {
  description = "The name of your GitHub repository."
  type        = string
  default     = "rsschool-devops-course-tasks"
}

variable "github_oidc_thumbprint" {
  description = "The thumbprint of the OIDC provider's root CA. Verify this from AWS/GitHub documentation."
  type        = string
  #default = "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  default = "2b18947a6a9fc7764fd8b5fb18a863b0c6dac24f"
}