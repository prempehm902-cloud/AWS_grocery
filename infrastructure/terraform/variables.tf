##############################
# AWS Provider
##############################
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

##############################
# EC2 Variables
##############################
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address allowed for SSH, in CIDR format (e.g., 123.45.67.89/32)"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for the EC2 instance (optional)"
  type        = string
  default     = null
}

##############################
# RDS Variables
##############################
variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
}

variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_subnet_group_name" {
  description = "Name for RDS subnet group"
  type        = string
  default     = "my-db-subnet-group-2"
}

##############################
# SNS / Monitoring
##############################
variable "sns_email" {
  description = "Email address to receive CloudWatch SNS alerts"
  type        = string
}

##############################
# VPC / Networking Variables
##############################
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "public_az" {
  description = "Availability zone for public subnet"
  type        = string
}

variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
}

variable "private_az_1" {
  description = "Availability zone for private subnet 1"
  type        = string
}

variable "private_az_2" {
  description = "Availability zone for private subnet 2"
  type        = string
}
