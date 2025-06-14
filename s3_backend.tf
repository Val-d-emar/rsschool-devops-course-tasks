# It should be noted that the S3 bucket used as a backend for storing Terraform state is
# usually created manually or via a separate Terraform configuration, and not within the same project
# that will use this bucket to store its state.
# This is because Terraform requires that a bucket to store its state already exists
# before initializing the backend (terraform init)

resource "aws_s3_bucket" "state" {
  bucket = var.state_bucket

}

resource "aws_s3_bucket_ownership_controls" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    object_ownership = "BucketOwnerPreferred"
    # or "ObjectWriter" If you need ACL in the future
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}