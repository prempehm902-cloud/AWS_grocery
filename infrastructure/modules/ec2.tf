# IAM Role
resource "aws_iam_role" "grocery_ec2_role" {
  name = "grocery_ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "policy_attach" {
  role       = aws_iam_role.grocery_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "grocery_ec2_role"
  role = aws_iam_role.grocery_ec2_role.name
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = "ami-0a6793a25df710b06"
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.app1_sg.id]
  subnet_id              = aws_subnet.public.id

  tags = {
    Name = "Prempeh-instance"
  }
}
