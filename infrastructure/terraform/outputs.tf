##############################
# EC2 Outputs
##############################

# EC2 Instance ID
output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.app_server.id
}

# EC2 Public IP
output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

# EC2 Private IP
output "ec2_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = aws_instance.app_server.private_ip
}

##############################
# RDS Outputs
##############################

# RDS Endpoint
output "db_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.app_db.endpoint
}

# RDS Instance ID
output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.app_db.id
}

##############################
# Security Groups
##############################

# Security group for EC2
output "app_security_group_id" {
  description = "Security group ID for EC2"
  value       = aws_security_group.app1_sg.id
}

# Security group for RDS
output "rds_security_group_id" {
  description = "Security group ID for RDS"
  value       = aws_security_group.rds_sg.id
}

##############################
# SNS & CloudWatch
##############################

# SNS Topic ARN
output "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alerts"
  value       = aws_sns_topic.topic.arn
}

# CloudWatch Alarm Name
output "cloudwatch_alarm_name" {
  description = "Name of the CloudWatch alarm monitoring EC2 CPU"
  value       = aws_cloudwatch_metric_alarm.my_watch.alarm_name
}

##############################
# Networking
##############################

# VPC ID
output "vpc_id" {
  description = "ID of the main VPC"
  value       = aws_vpc.main.id
}

# Public Subnet ID
output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

# Private Subnet IDs
output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

