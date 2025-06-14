terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  backend "s3" {
    # The name of the S3 bucket that will be used to store the Terraform state file.
    # As part of Task #1, this bucket must be created manually before running Terraform
    # but in the checks, a certain bucket must be created in the code, we will do it below...
    bucket  = "mybucketterraformname0"
    key     = "terraform.tfstate"
    region  = "eu-north-1" # Unfortunately variables are not allowed in this section.
    encrypt = true
    # dynamodb_table = var.lock_table #deprecated
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}
