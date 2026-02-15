variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_name" {
  description = "Name of the PostgreSQL database"
  type        = string
  default     = "grocerymate_db"
}

variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
  default     = "postgres"
}


variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true
}
