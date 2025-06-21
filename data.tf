// data.tf
# This file contains data sources for AWS resources used in the Terraform configuration.
data "aws_availability_zones" "available" {
  state = "available"
}