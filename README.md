# AWS Grocery Project

## Project Overview

AWS Grocery is a cloud-based application deployed on AWS. It features a fully managed and scalable infrastructure, including an EC2 instance, PostgreSQL RDS database, and an S3 bucket for storing user avatars. The application is containerized using Docker, ensuring consistent deployment across environments. A secure network setup is implemented using a VPC, subnets, security groups, and an internet gateway. Terraform is used for automated provisioning and management of all infrastructure components, enabling version-controlled, repeatable deployments.


##The infrastructure includes

Our system architecture includes the following components:

- EC2** for application hosting  
- Amazon RDS (PostgreSQL)** for persistent data storage  
- Amazon S3** for user avatar storage  
- Docker** for application containerization  
- VPC, subnets, security groups, and an Internet Gateway (IGW)** for secure networking  
- Elastic Load Balancer (ELB)** distributes incoming application traffic across multiple targets for high availability.  

All resources are provisioned and managed using **Terraform**, enabling repeatable, version-controlled deployments across environments.


### Architecture Diagram

The diagram below provides a visual overview of the infrastructure:

<img width="1536" height="1024" alt="AWS architecture diagram with VisualParadigm" src="https://github.com/user-attachments/assets/a2164bd9-8bbd-4b7f-bc8f-75084fbb86ee" />

[![AWS Architecture Diagram](https://github.com/user-attachments/assets/a2164bd9-8bbd-4b7f-bc8f-75084fbb86ee =800x533)](https://github.com/user-attachments/assets/a2164bd9-8bbd-4b7f-bc8f-75084fbb86ee)


## Table of Contents

[AWS Grocery Project](#aws-grocery-project)
  - [Project Overview](#project-overview)
  - [Architecture Diagram](#architecture-diagram)
  - [Prerequisites](#prerequisites)
  - [Terraform Setup](#terraform-setup)
    - [Terraform Outputs](#terraform-outputs)
  - [Usage](#usage)
  - [Notes and Best Practices](#notes-and-best-practices)
  - [Docker Setup](#docker-setup)


---
## Prerequisites

Ensure the following tools and accounts are available:
-Terraform >= 1.5.0
-AWS CLI (configured with valid credentials)
-Git
-Docker >= 25.0.13
-An active AWS account

---
## Terraform Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/prempehm902-cloud/AWS_grocery.git
   cd AWS_grocery/infrastructure

2. Initialize Terraform:

   terraform init

3. Review the Terraform plan:

    terraform plan

4. Apply the Terraform plan:

    terraform apply

Enter your RDS password when prompted. Must be >= 8. Only printable ASCII characters besides '/', '@', '"', ' ' may be used.


---

## List Terraform Outputs
Include a table of important outputs so users know what resources were created:

```markdown
Terraform Outputs

| Output | Example Value | Description |
|--------|---------------|-------------|
| `aws_region` | `eu-central-1` | AWS region where resources are deployed |
| `db_endpoint` | `terraform-xxxx.rds.amazonaws.com:5432` | RDS database endpoint |
| `db_instance_id` | `db-xxxxxxxx` | RDS instance ID |
| `ec2_instance_id` | `i-xxxxxxxx` | EC2 instance ID |
| `ec2_public_ip` | `18.196.156.153` | Public IP of the EC2 instance |
| `avatars_bucket_name` | `grocerymate-avatars-premps` | S3 bucket for avatars |

```
---
## Usage

- SSH into the EC2 instance:
  ```bash
  ssh -i <your-key.pem> ec2-user@<ec2_public_ip>

- Connect to PostgreSQL:

  psql -h <db_endpoint> -U <db_username> -d <db_name>

- Access S3 bucket via AWS CLI or console


Plan the deployment terraform plan Run the following command to see all resources terraform will create and check if matches your expection
terraform plan

Deploy the infrastructure terraform apply

Access the Application After deployment is complete, the web application can be access via the Elastic Load Balancer's DNS name. Copy the DNS name Terraform will output and paste it into your web browser.

Confirm Infrastructure Login to AWS console to confirm all the resources created


---

## Notes and Best Practices
```markdown
## Notes

- Do **not** commit `.terraform/` or Terraform state files; they are local only.
- Store passwords securely using Terraform variables with `sensitive = true`.
```


---
## Docker Setup

Docker Prerequisites
- Docker >= 25.0.13
- FROM python:3.9
- Git
- AWS account
  
1. Clone the repository (if not already done):

   git clone https://github.com/prempehm902-cloud/AWS_grocery.git
   cd AWS_grocery

2. Build the Docker image:

   docker build -t grocerymate-app 

3. Run the Docker container:

   docker run --network host grocerymate-app


4. Verify the container is running:

   docker ps


5. Your application should now be accessible on:
   
   docker run --network host -e S3_BUCKET_NAME=grocerymate-avatars-premps -e S3_REGION=eu-central-1  -e USE_S3_STORAGE=true grocerymate-app


6. Finally, Once the application is running, open your web browser and navigate to URL:

   - Local development (Docker running locally):
     http://localhost:5000
     
   - AWS deployment (EC2 instance):
     http://<EC2_PUBLIC_IP>:5000

7. Example:
   
      http://18.196.156.153:5000
