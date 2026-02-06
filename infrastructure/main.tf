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

# --------------------
# VPC
# --------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main-vpc"
  }
}

# --------------------
# Internet Gateway
# --------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# --------------------
# Public Subnet
# --------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-central-1a"

  tags = {
    Name = "public-subnet"
  }
}

# --------------------
# Private Subnets
# --------------------
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1c"

  tags = {
    Name = "private-subnet-2"
  }
}

# --------------------
# DB Subnet Group
# --------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

# --------------------
# Security Group - EC2
# --------------------
resource "aws_security_group" "app1_sg" {
  name        = "app1-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app1-sg"
  }
}

# --------------------
# Security Group - RDS
# --------------------
resource "aws_security_group" "rds_sg" {
  name        = "joy-rds-sg"
  description = "PostgreSQL access from EC2 only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app1_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-sg"
  }
}

# --------------------
# EC2 Instance
# --------------------
resource "aws_instance" "app_server" {
  ami                         = "ami-015f3aa67b494b27e"
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.app1_sg.id]

  tags = {
    Name = "app-server"
  }
}

# --------------------
# RDS Instance
# --------------------
resource "aws_db_instance" "app_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  skip_final_snapshot    = true
  publicly_accessible    = false

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  tags = {
    Name = "app-postgres-db"
  }
}

# --------------------
# Route Table (Public)
# --------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "public-route-table"
  }
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
