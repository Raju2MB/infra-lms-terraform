# VPC
resource "aws_vpc" "lms-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "lms"
  }
}

# Web Subnet
resource "aws_subnet" "lms-web-sn" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = ap-south-1
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lms-web-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "lms-db-sn" {
  vpc_id     = aws_vpc.lms-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = ap-south-1
  map_public_ip_on_launch = "false"

  tags = {
    Name = "lms-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "lms-igw" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-internet-gateway"
  }
}

# Web Route Table
resource "aws_route_table" "lms-web-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lms-igw.id
  }

  tags = {
    Name = "lms-web-route-table"
  }
}

# Database Route Table
resource "aws_route_table" "lms-database-rt" {
  vpc_id = aws_vpc.lms-vpc.id

  tags = {
    Name = "lms-database-route-table"
  }
}

# Web Subnet Association
resource "aws_route_table_association" "lms-web-asc" {
  subnet_id      = aws_subnet.lms-web-sn.id
  route_table_id = aws_route_table.lms-web-rt.id
}

# Database Subnet Association
resource "aws_route_table_association" "lms-database-asc" {
  subnet_id      = aws_subnet.lms-db-sn.id
  route_table_id = aws_route_table.lms-database-rt.id
}

# Web NACL
resource "aws_network_acl" "lms-web-nacl" {
  vpc_id = aws_vpc.lms-vpc.id
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-web-nacl"
  }
}

# Database NACL
resource "aws_network_acl" "lms-db-nacl" {
  vpc_id = aws_vpc.lms-vpc.id
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-db-nacl"
  }
}

# Web NACL Association
resource "aws_network_acl_association" "lms-web-nacl-asc" {
  network_acl_id = aws_network_acl.lms-web-nacl.id
  subnet_id      = aws_subnet.lms-web-sn.id
}

# Database NACL Association
resource "aws_network_acl_association" "lms-db-nacl-asc" {
  network_acl_id = aws_network_acl.lms-db-nacl.id
  subnet_id      = aws_subnet.lms-db-sn.id
}

# Web Security Group
resource "aws_security_group" "lms-web-sg" {
  name        = "lms-web-traffic"
  description = "Allow SSH - HTTP inbound traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  ingress {
    description = "SSH from WWW"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from WWW"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lms-web-sg"
  }
}

# Database Security Group
resource "aws_security_group" "lms-db-sg" {
  name        = "lms-db-traffic"
  description = "Allow SSH - Postgres inbound traffic"
  vpc_id      = aws_vpc.lms-vpc.id

  ingress {
    description = "SSH from WWW"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description = "Postgres from WWW"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lms-db-sg"
  }
}