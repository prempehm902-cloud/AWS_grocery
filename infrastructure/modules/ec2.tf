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
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })

  tags = merge(var.common_tags, { Name = "terraform_iam_role" })
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
# Fetch Latest Ubuntu AMI per region
# ---------------------------
data "aws_ami" "latest_ubuntu" {
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
  ami                    = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.latest_ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.app1_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  key_name               = var.ec2_key_name
  associate_public_ip_address = true

  tags = merge(var.common_tags, { Name = "Prempeh-instance" })
}
