# NETWORKING #
resource "aws_vpc" "FAST-vpc" {
  cidr_block           = "192.168.0.0/28"
  enable_dns_hostnames = true

  tags = {
    Name = "FAST-vpc"
  }
}

resource "aws_internet_gateway" "FAST-gateway" {
  vpc_id = aws_vpc.FAST-vpc.id
}

resource "aws_subnet" "FAST-subnet" {
  vpc_id                  = aws_vpc.FAST-vpc.id
  cidr_block              = "192.168.0.0/28"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "FAST-subnet"
  }
}

# ROUTING #
resource "aws_route_table" "FAST-route-table" {
  vpc_id = aws_vpc.FAST-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.FAST-gateway.id
  }
}

resource "aws_route_table_association" "FAST-subnet" {
  subnet_id      = aws_subnet.FAST-subnet.id
  route_table_id = aws_route_table.FAST-route-table.id
}

# SECURITY GROUP #
resource "aws_security_group" "FAST-sg" {
  name   = "FAST-sg"
  vpc_id = aws_vpc.FAST-vpc.id

  # SHH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 3389
    to_port    = 3389
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 3390
    to_port    = 3390
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ICMP IPv4 Either from 8 + to -1 or from -1 + to -1
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["192.168.0.0/28"]
  }

  # vsftpd 2.3.4
  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/28"]
  }

  # vsftpd 2.3.4 backdoor spawns on port 6200
  ingress {
    from_port   = 6200
    to_port     = 6200
    protocol    = "tcp"
    cidr_blocks = ["192.168.0.0/28"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "kali-vm" {
  ami           = var.kali_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.FAST-subnet.id
  
  vpc_security_group_ids = [aws_security_group.FAST-sg.id]

  user_data = var.kali_setup_script

  key_name = "terraform-key-pair"

  tags = {
    Name = "KALI-VM"
  }
}

resource "aws_instance" "vsftpd234-vm" {
  ami           = var.target_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.FAST-subnet.id
  
  vpc_security_group_ids = [aws_security_group.FAST-sg.id]

  user_data = var.target_setup_script

  key_name = "terraform-key-pair"

  tags = {
    Name = "Target-VM"
  }
}
