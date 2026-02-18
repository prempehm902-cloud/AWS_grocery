
# ---------------------------
# AWS region
# ---------------------------
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

# ---------------------------
# EC2 instance
# ---------------------------
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "ec2_ami" {
  description = "EC2 AMI ID. Can be dynamically fetched."
  type        = string
  default     = "ami-0a6793a25df710b06"
}

variable "ec2_key_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "Pee_masterschool"
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
  default     = "172.31.31.6"
}

# ---------------------------
# RDS / PostgreSQL
# ---------------------------
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "grocery-db"
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_subnet_group_name" {
  description = "Name of RDS subnet group"
  type        = string
}

variable "db_endpoint" {
  description = "RDS endpoint for grocery-db"
  type        = string
  default     = "grocery-db.cfqgiacie03r.eu-central-1.rds.amazonaws.com"
}

# ---------------------------
# SNS email
# ---------------------------
variable "sns_email" {
  description = "Email for CloudWatch alerts"
  type        = string
}

# ---------------------------
# VPC
# ---------------------------
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# ---------------------------
# Public subnet
# ---------------------------
variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_az" {
  description = "Availability zone for public subnet"
  type        = string
  default     = "eu-central-1a"
}

# ---------------------------
# Private subnets
# ---------------------------
variable "private_subnet_1_cidr" {
  description = "Private subnet 1 CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Private subnet 2 CIDR"
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_az_1" {
  description = "Availability zone for private subnet 1"
  type        = string
  default     = "eu-central-1b"
}

variable "private_az_2" {
  description = "Availability zone for private subnet 2"
  type        = string
  default     = "eu-central-1c"
}

variable "ec2_subnet_id" {
  description = "Subnet ID where EC2 instance will be launched"
  type        = string
  default     = "subnet-04fa2d03241c5b041"
}

# ---------------------------
# S3 Bucket
# ---------------------------
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "s3_bucket_tag_name" {
  description = "Tag Name for S3 bucket"
  type        = string
}
