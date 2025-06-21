// main.tf
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
    bucket       = "mybucketterraformname0"
    key          = "task2/terraform.tfstate"
    region       = "eu-north-1"
    use_lockfile = true # Use the S3-BASED lock to avoid Dynamodb costs
    # Although sources mention Dynamodb to block the condition,
    # Hashicorp documentation indicates that Dynamodb-Based Locking is outdated
    # Use 'us_Lockfile = True' allows you to use the S3-BASED lock, which is more
    # modern and does not require a separate Dynamodb table.
    # If you still decide to use Dynamodb to block (as in some training materials),
    # specify 'Dynamodb_table = "<Table_dynamodb_for_loking>"'
    # However, keep in mind that Dynamodb is rated and can lead to expenses.
  }
}

provider "aws" {
  region = var.aws_region
}

