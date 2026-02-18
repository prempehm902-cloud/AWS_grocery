# ---------------------------
# Terraform & Provider Setup
# ---------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ---------------------------
# Dynamic Availability Zones
# ---------------------------
data "aws_availability_zones" "available" {}

# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "main-vpc" }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# ---------------------------
# Public Subnet
# ---------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.public_az
  tags                    = { Name = "public-subnet" }
}

# ---------------------------
# Route Table for Public Subnet
# ---------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "public-route-table" }
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ---------------------------
# Private Subnets for RDS
# ---------------------------
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.private_az_1
  tags              = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.private_az_2
  tags              = { Name = "private-subnet-2" }
}

# ---------------------------
# RDS Subnet Group
# ---------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = var.db_subnet_group_name
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags       = { Name = var.db_subnet_group_name }
}

# ---------------------------
# Security Groups
# ---------------------------
resource "aws_security_group" "app1_sg" {
  name        = "app1-sg"
  description = "Allow SSH, HTTP, and Flask traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  description = "Allow PostgreSQL from EC2"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
    description     = "PostgreSQL access from EC2"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------
# IAM Role for EC2
# ---------------------------
resource "aws_iam_role" "grocery_ec2_role" {
  name = "grocery_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })

  tags = { Name = "terraform_iam_role" }
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.grocery_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "grocery_ec2_profile"
  role = aws_iam_role.grocery_ec2_role.name
}

# ---------------------------
# Dynamic AMI lookup for EC2
# ---------------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# ---------------------------
# EC2 Instance
# ---------------------------
resource "aws_instance" "app_server" {
  ami                    = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app1_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.ec2_key_name
  tags = { Name = "Prempeh-instance" }
}

# ---------------------------
# RDS Instance
# ---------------------------
resource "aws_db_instance" "app_db" {
  identifier             = var.db_name
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = var.db_instance_class
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  deletion_protection    = false
  multi_az               = false
  tags                   = { Name = "grocery-postgres-db" }
}

# ---------------------------
# SNS Topic for CloudWatch
# ---------------------------
resource "aws_sns_topic" "topic" {
  name = "app_server_cpu_alert"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = var.sns_email
}

# ---------------------------
# CloudWatch Alarm
# ---------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name                = "GroceryAlarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 95
  alarm_description         = "No description"
  treat_missing_data        = "missing"
  insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}
