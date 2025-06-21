# Task 2: Basic AWS Networking Infrastructure with Terraform

This Terraform project configures the basic networking infrastructure in AWS required for a Kubernetes (K8s) cluster or other applications requiring public and private subnets. This setup includes a VPC, public and private subnets across two Availability Zones, an Internet Gateway, a NAT Instance for outbound internet access from private subnets, a Bastion Host for secure access, and associated Security Groups and Network ACLs.

## Table of Contents

- [Infrastructure Overview](#infrastructure-overview)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
  - [Variables](#variables)
  - [Manual Setup Steps](#manual-setup-steps)
- [Deployment](#deployment)
- [Accessing the Bastion Host](#accessing-the-bastion-host)
- [Verifying Private Subnet Connectivity](#verifying-private-subnet-connectivity)
- [File Structure](#file-structure)
- [Key AWS Resources Created](#key-aws-resources-created)

## Infrastructure Overview

The following AWS resources will be created:

1.  **VPC:** A logically isolated virtual network.
2.  **Subnets:**
    *   **2 Public Subnets:** In different Availability Zones, with direct internet access via the Internet Gateway.
    *   **2 Private Subnets:** In different Availability Zones, with outbound internet access via a NAT Instance located in a public subnet.
3.  **Internet Gateway (IGW):** Allows communication between instances in the VPC and the internet (for public subnets).
4.  **NAT Instance:** An EC2 instance in a public subnet configured to perform Network Address Translation, allowing instances in private subnets to initiate outbound traffic to the internet while remaining private.
5.  **Route Tables:**
    *   **Public Route Table:** Directs internet-bound traffic from public subnets to the IGW.
    *   **Private Route Table:** Directs internet-bound traffic from private subnets to the NAT Instance.
6.  **Security Groups:**
    *   **Bastion Security Group:** Allows SSH access to the Bastion Host from a specified IP address.
    *   **NAT Instance Security Group:** Allows traffic from private subnets (for NATing) and necessary outbound traffic.
    *   **Private Instances Security Group:** Allows SSH access from the Bastion Host and ICMP for connectivity checks. Allows all outbound traffic (via NAT).
7.  **Network ACLs (NACLs):**
    *   **Public NACL:** Allows all inbound and outbound traffic for public subnets (fine-grained control delegated to Security Groups).
    *   **Private NACL:** Allows necessary inbound (e.g., return traffic for NAT, traffic from within VPC) and outbound traffic for private subnets.
8.  **Bastion Host:** An EC2 instance in a public subnet that serves as a secure jump-host to access resources in private subnets. It will have an Elastic IP.
9.  **Elastic IP (EIP):** Assigned to the Bastion Host for a static public IP address. (If you also added one for NAT instance, mention it).

*(A diagram or reference to the `task_2_schema.png` from the assignment would be excellent here if you can host it or if it's in your repo).*

## Prerequisites

1.  **Terraform:** Version `>= 1.10.0` (or your specified version) installed.
2.  **AWS CLI:** Installed and configured with appropriate credentials and default region. The IAM user/role should have permissions to create the resources defined in this project (VPC, EC2, IAM for data sources, S3 for backend, etc.).
3.  **AWS EC2 Key Pair:** An existing EC2 Key Pair in your target AWS region for SSH access to the Bastion and NAT instances.

## Configuration

### Variables

The following variables need to be configured, typically in `variables.tf` or by creating a `terraform.tfvars` file:

*   `aws_region`: (Default: `eu-north-1`) The AWS region where resources will be deployed.
*   `vpc_cidr`: (Default: `10.0.0.0/16`) The CIDR block for the VPC.
*   `public_subnets`: (Default: `["10.0.1.0/24", "10.0.2.0/24"]`) CIDR blocks for public subnets.
*   `private_subnets`: (Default: `["10.0.101.0/24", "10.0.102.0/24"]`) CIDR blocks for private subnets.
*   `key_pair_name`: **(Required)** The name of your existing EC2 Key Pair.
    *   _Example_: `MyKeyPair`
*   `my_ip_for_ssh`: **(Recommended)** Your public IP address (CIDR format, e.g., `YOUR_IP/32`) to restrict SSH access to the Bastion host. If not set, the bastion SG might default to `0.0.0.0/0` which is insecure. (Update this based on your actual SG implementation).
    *   _Example_: `123.45.67.89/32`
*   `bastion_ami_id` (if made a variable): The AMI ID for the Bastion host.
*   `bastion_instance_type` (if made a variable): The EC2 instance type for the Bastion host.
*   `nat_instance_type` (if made a variable): The EC2 instance type for the NAT instance.

**Example `terraform.tfvars` file:**
```tfvars
key_pair_name = "MyAwsKeyPair"
# my_ip_for_ssh = "YOUR_PUBLIC_IP/32" # Uncomment and set if you added this variable for bastion SG
```

### Manual Setup Steps

1.  **Create EC2 Key Pair:** If you haven't already, create an EC2 Key Pair in the target AWS region via the AWS Management Console (EC2 -> Key Pairs -> Create key pair). Download the `.pem` file and store it securely. Provide its name to the `key_pair_name` variable.
2.  **(If using S3 Backend)** Ensure the S3 bucket (`mybucketterraformname0` in your example) and DynamoDB table (if used for locking) for the Terraform backend are already created (e.g., from Task 1 bootstrap or a separate bootstrap process).

## Deployment

1.  **Clone the repository (if applicable) and navigate to the `task_2` directory:**
    ```bash
    # git clone ...
    cd path/to/your/project/task_2
    ```

2.  **Initialize Terraform:**
    Downloads necessary provider plugins and configures the backend.
    ```bash
    terraform init
    ```

3.  **Review the execution plan:**
    Shows what resources Terraform will create, modify, or destroy.
    ```bash
    terraform plan
    ```

4.  **Apply the configuration:**
    Creates the infrastructure in your AWS account.
    ```bash
    terraform apply
    ```
    Confirm the action by typing `yes` when prompted.

## Accessing the Bastion Host

1.  **Get the Bastion Host's Public IP:**
    After `terraform apply` completes, the public IP of the bastion host will be an output (or find its Elastic IP in the AWS EC2 Console).
    ```bash
    terraform output bastion_public_ip # If you have this output
    ```

2.  **SSH into the Bastion Host:**
    Replace `/path/to/your/key.pem` with the actual path to your private key file, `YourKeyPairName` with the name of your key pair, and `BASTION_PUBLIC_IP` with the IP address. The username (`ec2-user`) is common for Amazon Linux AMIs; it might differ for other AMIs.
    ```bash
    ssh -i /path/to/your/YourKeyPairName.pem ec2-user@BASTION_PUBLIC_IP
    ```

## Verifying Private Subnet Connectivity

Once connected to the bastion host, you can:

1.  **Launch an EC2 instance manually in one of the private subnets** (ensure it uses a Security Group that allows SSH from the Bastion's Security Group or private IP).
2.  **SSH from the bastion to this private instance:**
    ```bash
    # On bastion:
    ssh -i /path/to/your/YourKeyPairName.pem ec2-user@PRIVATE_INSTANCE_IP
    ```
3.  **On the private instance, test internet connectivity:**
    ```bash
    # On private instance:
    ping google.com
    curl -I https://www.google.com
    ```
    If the NAT Instance and routing are configured correctly, these commands should succeed.

## File Structure

```
task_2/
├── main.tf                 # Provider, Backend configuration
├── variables.tf            # Input variables
├── data.tf                 # Data sources (e.g., Availability Zones, AMI for NAT)
├── vpc.tf                  # VPC resource
├── subnets.tf              # Public and Private subnets
├── igw.tf                  # Internet Gateway
├── route_tables.tf         # Public and Private route tables and associations
├── nat.tf                  # NAT Instance and its Security Group
├── bastion.tf              # Bastion Host EC2 instance (and EIP if added)
├── security_groups.tf      # Bastion and Private instance Security Groups
├── security_group_rules.tf # Specific rules for Security Groups
├── nacl.tf                 # Network ACLs for public and private subnets
├── outputs.tf              # Terraform outputs (e.g., IPs, IDs)
└── README.md               # This file
```

## Key AWS Resources Created

*   `aws_vpc.main`: The main virtual private cloud.
*   `aws_subnet.public[*]`: Public subnets.
*   `aws_subnet.private[*]`: Private subnets.
*   `aws_internet_gateway.igw`: Internet Gateway for public subnets.
*   `aws_route_table.public`: Route table for public subnets.
*   `aws_route_table.private`: Route table for private subnets.
*   `aws_instance.nat`: The NAT instance providing internet access for private subnets.
*   `aws_security_group.nat_sg`: Security group for the NAT instance.
*   `aws_instance.bastion`: The Bastion host.
*   `aws_security_group.bastion_sg`: Security group for the Bastion host.
*   `aws_security_group.private_sg`: Security group for (future) instances in private subnets.
*   `aws_network_acl.public[*]`: Network ACLs for public subnets.
*   `aws_network_acl.private[*]`: Network ACLs for private subnets.
*   (If added) `aws_eip.bastion`: Elastic IP for the Bastion host.

