# -----------------------------------
# RDS Subnet Group (Private Subnets)
# -----------------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = var.db_subnet_group_name

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

# -----------------------------------
# RDS PostgreSQL Instance
# -----------------------------------
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

  publicly_accessible    = false      # 🔐 keep DB private
  multi_az               = false
  skip_final_snapshot    = true

  deletion_protection    = false

  tags = {
    Name = "grocery-postgres-db"
  }
}
