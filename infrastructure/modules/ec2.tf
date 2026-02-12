
variable "subnet_id" {}
variable "security_group_id" {}
variable "instance_type" {}

resource "aws_instance" "app_server" {
  ami                    = "ami-015f3aa67b494b27e"
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
}

output "instance_id" {
  value = aws_instance.app_server.id
}
