 AWS region to deploy resources
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

# EC2 instance type
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

# EC2 AMI (optional, recommended to avoid hardcoding AMI IDs)
variable "ec2_ami" {
  description = "AMI ID for EC2 instance. Use a regional AMI or dynamically look it up"
  type        = string
}

# PostgreSQL database name
variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
}

# PostgreSQL master username
variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
}

# PostgreSQL master password (sensitive)
variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true
}

# Your public IP to allow SSH access
variable "my_ip" {
  description = "Your public IP address allowed for SSH, in CIDR format (e.g., 123.45.67.89/32)"
  type        = string
}

# Optional: DB instance class
variable "db_instance_class" {
  description = "RDS instance class type"
  type        = string
  default     = "db.t3.micro"
}

# Optional: SNS email for alarms
variable "sns_email" {
  description = "Email address to receive CloudWatch SNS alerts"
  type        = string
}
