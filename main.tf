# NETWORKING #
resource "aws_vpc" "FAST-vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "FAST-vpc"
  }
}

resource "aws_internet_gateway" "FAST-gateway" {
  vpc_id = aws_vpc.FAST-vpc.id
}

resource "aws_route_table" "FAST-route-table" {
  vpc_id = aws_vpc.FAST-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.FAST-gateway.id
  }
}

variable "attendee_usernames" {
  type = list(string)

  default = [
    "rastley",
    "ewatson",
    "rreynolds"
  ]
}


locals {
  attendee_index_map = zipmap(var.attendee_usernames, range(length(var.attendee_usernames)))
}


module "vsftpd234-lab" {
    source = "./modules/vsftpd234-lab"
    for_each = local.attendee_index_map

    attendee_number = each.value
    vpc_id          = aws_vpc.FAST-vpc.id
    route_table_id  = aws_route_table.FAST-route-table.id
}