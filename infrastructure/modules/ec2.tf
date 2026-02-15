# Variables
variable "ami" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 instance will be deployed"
  type        = string
}

variable "security_group_id" {
  description = "Security group ID to assign to EC2 instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile for the EC2 instance"
  type        = string
  default     = null
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  # Optional IAM profile
  iam_instance_profile = var.iam_instance_profile

  # Optional: assign a name tag
  tags = {
    Name = "AppServer"
  }
}

# Outputs
output "instance_id" {
  value = aws_instance.app_server.id
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}

output "private_ip" {
  value = aws_instance.app_server.private_ip
}
