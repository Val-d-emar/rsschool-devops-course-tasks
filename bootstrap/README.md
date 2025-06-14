# Terraform AWS Bootstrap: S3 Backend & GitHub Actions IAM Setup

This directory contains the Terraform configuration to perform a one-time bootstrap of essential AWS resources required for your main infrastructure project and its CI/CD pipeline.

**Purpose:**
1.  To create and configure an S3 bucket for securely storing the Terraform state of your main project.
2.  To set up the AWS IAM OpenID Connect (OIDC) provider for GitHub Actions.
3.  To create the IAM Role that GitHub Actions will assume to deploy and manage resources in your AWS account.

**When to use:** This configuration should be run **once locally** before setting up your main Terraform project's S3 backend and configuring your GitHub Actions CI/CD pipeline. Once these resources are created, this bootstrap configuration is generally not needed for regular operations, unless you need to recreate or fundamentally change these core bootstrap resources.

## Directory Structure

It's assumed your `bootstrap` directory will contain:

```
bootstrap/
├── bootstrap_main.tf               # Main Terraform provider configuration
├── bootstrap_variables.tf          # Variables for all bootstrap resources
├── bootstrap_s3_bucket.tf          # Resources for S3 state bucket
├── bootstrap_iam_oidc_provider.tf  # Resource for IAM OIDC Provider for GitHub
├── bootstrap_iam_role_gh_actions.tf # Resources for GitHub Actions IAM Role
└── README.md                       # This file
```

## Prerequisites

1.  **AWS CLI Installed and Configured:** Ensure the AWS CLI is installed and configured with IAM user credentials that have sufficient permissions to:
    *   Create and manage S3 buckets (e.g., `AmazonS3FullAccess`).
    *   Create and manage IAM OIDC providers and IAM Roles (e.g., `IAMFullAccess`).
    ```bash
    aws configure
    ```
2.  **Terraform Installed:** Ensure Terraform (a version compatible with the code, e.g., >= 1.6.0) is installed on your local machine.
    ```bash
    terraform version
    ```

## Configuration

Key configuration parameters should be defined in `bootstrap_variables.tf`:

**For S3 State Bucket:**
*   `aws_region`: The AWS region for all resources. Example: `eu-north-1`.
*   `state_bucket_name`: A globally unique name for the S3 bucket that will store Terraform state. Example: `my-tf-state-bucket-unique-12345`.

**For GitHub Actions IAM Role & OIDC:**
*   `github_org_or_username`: Your GitHub organization or username. Example: `Val-d-emar`.
*   `github_repository_name`: The name of your GitHub repository that will use this role. Example: `rsschool-devops-course-tasks`.
*   `github_oidc_thumbprint`: The thumbprint of the GitHub OIDC provider's root CA. *Verify the current thumbprint from official AWS/GitHub documentation.* Example: `1c58a3a8518e8759bf075b76b750d4f2df264fcd`.
*   `github_actions_iam_role_name`: The name for the IAM role. Example: `GithubActionsRole`.

Modify the default values in `bootstrap_variables.tf` or create a `terraform.tfvars` file in this `bootstrap` directory to override them:

```terraform
// Example terraform.tfvars
// aws_region                 = "us-east-1"
// state_bucket_name          = "your-globally-unique-s3-bucket-name"
// github_org_or_username     = "your-github-username"
// github_repository_name     = "your-repo-name"
// github_actions_iam_role_name = "CustomGitHubActionsRole"
```

## Usage

1.  **Navigate to the `bootstrap` directory:**
    ```bash
    cd path/to/your/project/bootstrap
    ```

2.  **Initialize Terraform:**
    This downloads the necessary provider plugins.
    ```bash
    terraform init
    ```

3.  **Create an execution plan (optional, but recommended):**
    This shows what resources Terraform will create.
    ```bash
    terraform plan
    ```

4.  **Apply the configuration:**
    This creates the S3 bucket, IAM OIDC provider, and IAM Role in your AWS account.
    ```bash
    terraform apply
    ```
    You will be prompted to confirm the resource creation. Type `yes`.

## Outcome

Upon successful execution of `terraform apply`, the following resources will be created:

**S3 State Storage:**
*   **S3 Bucket:** With the specified name, versioning, public access block, and server-side encryption.

**GitHub Actions Integration:**
*   **IAM OIDC Provider:** Configured for `https://token.actions.githubusercontent.com`.
*   **IAM Role:** (`GithubActionsRole` or your custom name) with:
    *   A trust policy allowing GitHub Actions from your specified repository to assume this role via OIDC.
    *   Attached IAM policies granting necessary permissions (e.g., `AmazonEC2FullAccess`, `AmazonS3FullAccess`, etc., as defined in your Terraform code for the role).

## Next Steps

After successfully bootstrapping these resources:

1.  **Configure S3 Backend in Main Project:**
    *   Update the `backend "s3"` block in your **main** Terraform project (outside this `bootstrap` directory) to use the `state_bucket_name` and `aws_region` you just created.
    Example:
    ```terraform
    terraform {
      backend "s3" {
        bucket         = "name-of-your-created-s3-bucket" // From bootstrap_variables.tf
        key            = "main_project/terraform.tfstate" // Or your desired state file path
        region         = "your-aws-region"                // From bootstrap_variables.tf
        encrypt        = true
      }
    }
    ```

2.  **Configure GitHub Actions Secrets:**
    *   In your GitHub repository (`${github_org_or_username}/${github_repository_name}`), go to `Settings` > `Secrets and variables` > `Actions`.
    *   Create a new repository secret (e.g., `AWS_GITHUB_ROLE_ARN`).
    *   The value for this secret is the **ARN** of the IAM Role (`GithubActionsRole`) created by this bootstrap process. You can get this ARN from the output of `terraform apply` if you add an output block for it, or find it in the AWS IAM console.
    Example output to add to your `bootstrap_iam_role_gh_actions.tf`:
    ```terraform
    output "github_actions_role_arn" {
      description = "The ARN of the IAM role for GitHub Actions"
      value       = aws_iam_role.github_actions_role.arn // Assuming your role resource is named "github_actions_role"
    }
    ```

3.  **Initialize Main Project & CI/CD:**
    *   You can now initialize (`terraform init`) your main Terraform project. It will use the S3 backend.
    *   Your GitHub Actions workflow, using `aws-actions/configure-aws-credentials` with the `AWS_GITHUB_ROLE_ARN` secret, will now be able to assume the created role and manage resources as defined in your main project's Terraform code.

4.  **Managing Bootstrap Resources:**
    *   The resources created by this `bootstrap` configuration are foundational. If you need to change them (e.g., update role permissions not managed by the main pipeline, or change OIDC settings), you would typically re-run `terraform apply` in this `bootstrap` directory.
    *   Your main CI/CD pipeline **should not** attempt to manage the IAM OIDC provider or the specific IAM role it uses for authentication if they are solely defined and created by this bootstrap process. It will *use* the role.
