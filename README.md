# [DevOps Course](https://github.com/rolling-scopes-school/tasks/tree/master/devops)
The course aims to offer in-depth knowledge of DevOps principles and essential AWS services necessary for efficient automation and infrastructure management. Participants will gain practical skills in setting up, deploying, and managing Kubernetes clusters on AWS, using tools like K3s and Terraform, Jenkins and monitoring tools.

~~~
 Repository Structure
.
├── main.tf              # Terraform backend & provider
├── variables.tf         # Variable definitions
├── s3_backend.tf        # S3 bucket, versioning, encryption, ownership
├── tf.plan.txt          # Terraform plan first output
├── tf.apply.txt         # Terraform apply first output
├── screenshots/*        # screenshots of tasks pass
└── .github/workflows/terraform.yml  # CI/CD pipeline via GitHub Actions
~~~

# Additional Tasks: Infrastructure Documentation

This repository contains Terraform code and a GitHub Actions CI/CD pipeline for **Task 1**, including all **Additional Tasks** (20 points).

## Repository Overview

- **Remote state via S3 backend**, with best practices:
  - Separate resources for versioning, encryption, and ownership controls
- **IAM role** and **OIDC Identity Provider** setup to allow secure GitHub Actions access
- **GitHub Actions workflow** with `fmt`, `plan`, and `apply` stages

## Infrastructure Components

1. **S3 Backend (`s3_backend.tf`)**
   - **Bucket**: created without `acl` to avoid ACL-related errors
   - **Ownership Controls**: sets `BucketOwnerPreferred`, disabling ACLs and avoiding `AccessControlListNotSupported`
   - **Versioning**: enabled via `aws_s3_bucket_versioning`
   - **Encryption**: enabled via `aws_s3_bucket_server_side_encryption_configuration` with AES‑256

2. **IAM & OIDC Setup**
   - Creates GithubActions Role with required AWS policies
   - Configures OIDC Identity Provider for GitHub
   - Ensures secure trust policy scoped to the GitHub organization and repository

3. **Backend Configuration (`main.tf`)**
   - Defines S3 backend with **static values** (required—Terraform does not allow variables inside `backend` block)

4. **CI/CD Pipeline (`.github/workflows/terraform.yml`)**
   - `terraform-check`: runs `terraform fmt`
   - `terraform-plan`: runs `terraform init` and `terraform plan`
   - `terraform-apply`: runs `terraform apply` only on `main` branch

## Setup & Usage

1. Install **AWS CLI v2** and **Terraform 1.6+**
1. Create AWS IAM user with required permissions and enable MFA
1. Create GithubActions Role with required AWS policies
1. Creates Backet with required AWS policies
1. Run:
   ```bash
   aws configure
   terraform init
   terraform plan -out=tfplan
   terraform apply tfplan
