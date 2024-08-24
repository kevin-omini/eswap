# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "eswap-vpc"
    Environment = "dev"
  }
}


# Create a public subnet 
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name        = "eswap-public-subnet"
    Environment = "dev"
  }
}


# Create a private subnet 
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name        = "eswap-private-subnet"
    Environment = "dev"
  }
}


# Create an IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "eswap-igw"
    Environment = "dev"
  }
}


# Create a route table for public subnet 
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "eswap-public-route-table"
    Environment = "dev"
  }
}


# Route table association for public subnet 
resource "aws_route_table_association" "publi__rt-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}
