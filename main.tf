# creation of vpc (IBM)
resource "aws_vpc" "IBM-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "IBM"
  }
}

#websubnet
resource "aws_subnet" "IBM-web-subnet" {
  vpc_id     = aws_vpc.IBM-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "IBM-web-subnet"
  }
}

# Database subnet
resource "aws_subnet" "IBM-database-subnet" {
  vpc_id     = aws_vpc.IBM-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "IBM-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "IBM-Igw" {
  vpc_id = aws_vpc.IBM-vpc.id

  tags = {
    Name = "IBM-Igw"
  }
}

# web route table
resource "aws_route_table" "IBM-web-rt" {
  vpc_id = aws_vpc.IBM-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IBM-Igw.id
  }

  tags = {
    Name = "IBM-web-rt"
  }
}

# database route table
resource "aws_route_table" "IBM-database-rt" {
  vpc_id = aws_vpc.IBM-vpc.id

  tags = {
    Name = "IBM-web-rt"
  }
}

# web subnet association
resource "aws_route_table_association" "IBM-web-ass" {
  subnet_id      = aws_subnet.IBM-web-subnet.id
  route_table_id = aws_route_table.IBM-web-rt.id
}

# database subnet association
resource "aws_route_table_association" "IBM-database-ass" {
  subnet_id      = aws_subnet.IBM-database-subnet.id
  route_table_id = aws_route_table.IBM-database-rt.id
}

# web NACL
resource "aws_network_acl" "IBM-web-nacl" {
  vpc_id = aws_vpc.IBM-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "IBM-web-nacl"
  }
}

# database NACL
resource "aws_network_acl" "IBM-database-nacl" {
  vpc_id = aws_vpc.IBM-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.3.0.0/18"
    from_port  = 80
    to_port    = 80
  }

  tags = {
    Name = "IBM-database-nacl"
  }
}

# web NACL association
resource "aws_network_acl_association" "IBM-web-NACL-ass" {
  network_acl_id = aws_network_acl.IBM-web-nacl.id
  subnet_id      = aws_subnet.IBM-web-subnet.id
}

# database NACL association
resource "aws_network_acl_association" "IBM-database-NACL-ass" {
  network_acl_id = aws_network_acl.IBM-database-nacl.id
  subnet_id      = aws_subnet.IBM-database-subnet.id
}

# web security groups
resource "aws_security_group" "IBM-web-sg" {
  name        = "IBM-web-traffic"
  description = "Allow SSH - HTTP inbound traffic"
  vpc_id      = aws_vpc.IBM-vpc.id

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
    Name = "IBM-web-sg"
  }
}

# database security groups
resource "aws_security_group" "IBM-database-sg" {
  name        = "IBM-database-traffic"
  description = "Allow SSH - Postgres inbound traffic"
  vpc_id      = aws_vpc.IBM-vpc.id

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
    Name = "IBM-database-sg"
  }
}

# ec2 instence creation
resource "aws_instance" "web" {
  ami           = "ami-05c969369880fa2c2"
  key_name = "IBM"
  instance_type = "t3.micro"
  subnet_id = aws_subnet.IBM-web-subnet.id
  vpc_security_group_ids =[aws_security_group.IBM-web-sg.id]

  tags = {
    Name = "web-server"
  }
}






