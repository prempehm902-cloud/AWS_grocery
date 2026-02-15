# Variables
variable "subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

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

variable "ec2_security_group" {
  description = "EC2 security group ID allowed to access RDS"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class type"
  type        = string
  default     = "db.t3.micro"
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids
}

# Security Group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  # Allow PostgreSQL only from EC2 security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.ec2_security_group]
    description     = "PostgreSQL access from EC2"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# RDS Instance
resource "aws_db_instance" "app_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
}

# Outputs
output "db_instance_id" {
  value = aws_db_instance.app_db.id
}

output "db_endpoint" {
  value = aws_db_instance.app_db.endpoint
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.rds_subnet_group.name
}

 
