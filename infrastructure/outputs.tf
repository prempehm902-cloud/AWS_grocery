# =========================
# EC2 Outputs
# =========================
output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

# =========================
# RDS Outputs
# =========================
output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.app_db.endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.app_db.id
}

# =========================
# S3 Outputs
# =========================
output "avatars_bucket_name" {
  description = "S3 bucket for avatars"
  value       = aws_s3_bucket.avatars.id
}

# =========================
# VPC / Networking Outputs
# =========================
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.main.id
}

# =========================
# AWS Region
# =========================
output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.region
}