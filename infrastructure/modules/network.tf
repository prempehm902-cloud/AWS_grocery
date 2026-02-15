# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public Subnet
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_az" {
  description = "Availability Zone for the public subnet"
  type        = string
  default     = "eu-central-1a"
}

# Private Subnets
variable "private_subnet_1_cidr" {
  description = "CIDR block for private subnet 1"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_2_cidr" {
  description = "CIDR block for private subnet 2"
  type        = string
  default     = "10.0.4.0/24"
}

variable "private_az_1" {
  description = "Availability Zone for private subnet 1"
  type        = string
  default     = "eu-central-1b"
}

variable "private_az_2" {
  description = "Availability Zone for private subnet 2"
  type        = string
  default     = "eu-central-1c"
}

# DB Subnet Group
variable "db_subnet_group_name" {
  description = "Name for RDS DB subnet group"
  type        = string
  default     = "my-db-subnet-group"
}
