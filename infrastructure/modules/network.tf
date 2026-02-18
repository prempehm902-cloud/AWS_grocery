# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.common_tags, { Name = "main-vpc" })
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "main-igw" })
}

# ---------------------------
# Public Subnet
# ---------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.public_az
  tags                    = merge(var.common_tags, { Name = "public-subnet" })
}

# ---------------------------
# Private Subnets
# ---------------------------
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.private_az_1
  tags              = merge(var.common_tags, { Name = "private-subnet-1" })
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.private_az_2
  tags              = merge(var.common_tags, { Name = "private-subnet-2" })
}

# ---------------------------
# Public Route Table
# ---------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.common_tags, { Name = "public-route-table" })
}

resource "aws_route" "internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

