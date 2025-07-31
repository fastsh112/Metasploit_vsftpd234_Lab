resource "aws_subnet" "FAST-subnet" {
  vpc_id                  = var.vpc_id
  cidr_block              = "192.168.${var.attendee_number}.0/28"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "FAST-subnet-${var.attendee_number}"
  }
}

resource "aws_route_table_association" "FAST-subnet" {
  subnet_id      = aws_subnet.FAST-subnet.id
  route_table_id = var.route_table_id
}

# SECURITY GROUP #
resource "aws_security_group" "FAST-sg" {
  name   = "FAST-sg-${var.attendee_number}"
  vpc_id = var.vpc_id

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
    cidr_blocks = [aws_subnet.FAST-subnet.cidr_block]
  }

  # vsftpd 2.3.4
  ingress {
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.FAST-subnet.cidr_block]
  }

  # vsftpd 2.3.4 backdoor spawns on port 6200
  ingress {
    from_port   = 6200
    to_port     = 6200
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.FAST-subnet.cidr_block]
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

  private_ip = "192.168.${var.attendee_number}.11"
  
  vpc_security_group_ids = [aws_security_group.FAST-sg.id]

  user_data = var.kali_setup_script

  key_name = "terraform-key-pair"

  tags = {
    Name = "KALI-VM-${var.attendee_number}"
  }
}

resource "aws_instance" "vsftpd234-vm" {
  ami           = var.target_ami
  instance_type = var.instance_type
  subnet_id     = aws_subnet.FAST-subnet.id

  private_ip = "192.168.${var.attendee_number}.10"
  
  vpc_security_group_ids = [aws_security_group.FAST-sg.id]

  user_data = var.target_setup_script

  key_name = "terraform-key-pair"

  tags = {
    Name = "Target-VM-${var.attendee_number}"
  }
}