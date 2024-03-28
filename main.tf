# creation of vpc (LMS)
resource "aws_vpc" "LMS-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "LMS"
  }
}

#websubnet
resource "aws_subnet" "LMS-web-subnet" {
  vpc_id     = aws_vpc.LMS-vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "LMS-web-subnet"
  }
}

# Database subnet
resource "aws_subnet" "LMS-database-subnet" {
  vpc_id     = aws_vpc.LMS-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "LMS-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "LMS-Igw" {
  vpc_id = aws_vpc.LMS-vpc.id

  tags = {
    Name = "LMS-Igw"
  }
}

# web route table
resource "aws_route_table" "LMS-web-rt" {
  vpc_id = aws_vpc.LMS-vpc.id

  route { 
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.LMS-Igw.id
  }

  tags = {
    Name = "LMS-web-rt"
  }
}

# database route table
resource "aws_route_table" "LMS-database-rt" {
  vpc_id = aws_vpc.LMS-vpc.id

  tags = {
    Name = "LMS-database-rt"
  }
}

# web subnet association
resource "aws_route_table_association" "LMS-web-ass" {
  subnet_id      = aws_subnet.LMS-web-subnet.id
  route_table_id = aws_route_table.LMS-web-rt.id
}

# database subnet association
resource "aws_route_table_association" "LMS-database-ass" {
  subnet_id      = aws_subnet.LMS-database-subnet.id
  route_table_id = aws_route_table.LMS-database-rt.id
}

# web NACL
resource "aws_network_acl" "LMS-web-nacl" {
  vpc_id = aws_vpc.LMS-vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "LMS-web-nacl"
  }
}

# database NACL
resource "aws_network_acl" "LMS-database-nacl" {
  vpc_id = aws_vpc.LMS-vpc.id

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
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "LMS-database-nacl"
  }
}

# web NACL association
resource "aws_network_acl_association" "LMS-web-NACL-ass" {
  network_acl_id = aws_network_acl.LMS-web-nacl.id
  subnet_id      = aws_subnet.LMS-web-subnet.id
}

# database NACL association
resource "aws_network_acl_association" "LMS-database-NACL-ass" {
  network_acl_id = aws_network_acl.LMS-database-nacl.id
  subnet_id      = aws_subnet.LMS-database-subnet.id
}

# web security groups
resource "aws_security_group" "LMS-web-sg" {
  name        = "LMS-web-traffic"
  description = "Allow SSH - HTTP inbound traffic"
  vpc_id      = aws_vpc.LMS-vpc.id

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
  ingress {
    description = "Jenkins from WWW"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Sonarqube from WWW"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "nexus from WWW"
    from_port   = 8081
    to_port     = 8081
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
    Name = "LMS-web-sg"
  }
}

# database security groups
resource "aws_security_group" "LMS-database-sg" {
  name        = "LMS-database-traffic"
  description = "Allow SSH - Postgres inbound traffic"
  vpc_id      = aws_vpc.LMS-vpc.id

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
    Name = "LMS-database-sg"
  }
}

# ec2 instence creation
resource "aws_instance" "Jenkins" {
  ami           = "ami-007020fd9c84e18c7"
  key_name = "LMS"
  instance_type = "t2.large"
  subnet_id = aws_subnet.LMS-web-subnet.id
  vpc_security_group_ids =[aws_security_group.LMS-web-sg.id]
  user_data = templatefile("./install_Jenkins.sh",{})

  tags = {
    Name = "LMS_Jenkins"
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
}

resource "aws_instance" "SonarQube-nexus" {
  ami           = "ami-007020fd9c84e18c7"
  key_name = "LMS"
  instance_type = "t2.large"
  subnet_id = aws_subnet.LMS-web-subnet.id
  vpc_security_group_ids =[aws_security_group.LMS-web-sg.id]
  user_data = templatefile("./install_sonarqube_nexus.sh",{})

  tags = {
    Name = "LMS_SonarQube-nexus"
  }
  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }
}