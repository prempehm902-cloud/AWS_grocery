terraform {
 required_providers {
  aws = {
   source = "hashicorp/aws"
   version = "~> 5.0"
  }
 }
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "main-vpc" }
}

# INTERNET GATEWAY
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}

# PUBLIC SUBNET
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"

  tags = { Name = "public-subnet" }
}

# ROUTE TABLE
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "public-route-table" }
}

# ROUTE TO INTERNET
resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# ASSOCIATE WITH SUBNET
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

  # PRIVATE SUBNET 1
  resource "aws_subnet" "private_subnet_1" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "eu-central-1b"
    tags = {
      Name = "Private Subnet-1"
    }
  }
  # PRIVATE SUBNET 2
  resource "aws_subnet" "private_subnet_2" {
    vpc_id     = aws_vpc.main.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "eu-central-1c"
    tags = {
      Name = "Private Subnet-2"
    }
  }
# COMBINE PRIVATE SUBNETS
  resource "aws_db_subnet_group" "rds_subnet_group" {
    name       = "my-db-subnet-group"
    subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id ]  #if multi AZ add another subnet
  }


resource "aws_security_group" "app1_sg" {
  name        = "app1-sg"
  description = "Allow SSH, HTTP, and Flask app traffic"
  vpc_id      = aws_vpc.main.id


  # Allow SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_iam_role" "grocery_ec2_role" {
  name = "grocery_ec2_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "terraform_iam_role"
  }
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = aws_iam_role.grocery_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "joy_ec2_profile" {
  name = "grocery_ec2_role"
  role = aws_iam_role.grocery_ec2_role.name
}

# EC2 INSTANCE
resource "aws_instance" "app_server" {
  ami           = "ami-015f3aa67b494b27e"
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.joy_ec2_profile.name
  vpc_security_group_ids = [aws_security_group.app1_sg.id]
  subnet_id = aws_subnet.public.id

}

# SECURITY GROUP FOR RDS
resource "aws_security_group" "rds_sg" {
  name        = "joy-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      = aws_vpc.main.id

  # postgresSQL ACCESS ONLY FROM EC2
 ingress {
  from_port   = 5432
  to_port     = 5432
  protocol    = "tcp"
  security_groups = [aws_security_group.app1_sg.id]
  description = "PostgresSQL access from EC2 subnet"
}


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

# DB INSTANCE
resource "aws_db_instance" "app_db" {
 allocated_storage = 20
 engine = "postgres"
 engine_version = "17.6"
 instance_class = "db.t3.micro"
 db_name = var.db_name
 username = var.db_username
 password = var.db_password
 skip_final_snapshot = true
  vpc_security_group_ids = [aws_security_group.app1_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
}


# SNS topic with email subscription
resource "aws_sns_topic" "topic" {
  name = "app_server-CPU_Utilization_alert"
}
resource "aws_sns_topic_subscription" "topic_email_subscription" {
  topic_arn = aws_sns_topic.topic.arn
  protocol  = "email"
  endpoint  = "peridiant@gmail.com"
}

# CloudWatch Alarm for EC2
resource "aws_cloudwatch_metric_alarm" "my_watch" {
  alarm_name                = "GroceryAlarm"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 300  # 5 minutes in seconds
  statistic                 = "Average"
  threshold                 = 95
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions             = [aws_sns_topic.topic.arn]
  dimensions = {
    InstanceId = aws_instance.app_server.id
  }
}
