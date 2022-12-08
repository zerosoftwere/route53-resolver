# VPC 10.10.0.0/16

resource "aws_vpc" "premise" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "Premise VPC"
  }
}

# Public subnet

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.premise.id
  cidr_block              = "10.20.0.0/24"
  availability_zone       = "${var.REGION}a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Premise Public a"
  }
}

# Private subnets

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.premise.id
  cidr_block        = "10.20.1.0/24"
  availability_zone = "${var.REGION}b"

  tags = {
    "Name" = "Premise Private b"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.premise.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "${var.REGION}c"

  tags = {
    "Name" = "Premise Private c"
  }
}

# Internet gateway, route table and route table association

resource "aws_internet_gateway" "premise" {
  vpc_id = aws_vpc.premise.id
}

resource "aws_eip" "nat_eip" {

}

resource "aws_nat_gateway" "premise" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id
  tags = {
    "Name" = "Premise NGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.premise.id

  tags = {
    "Name" = "Premise public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.premise.id
  }
}

resource "aws_route_table_association" "premise_public_rta" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.premise.id
  tags = {
    "Name" = "Premise private"
  }

  route {
    cidr_block           = "10.10.0.0/16"
    network_interface_id = aws_instance.vpn.primary_network_interface_id
    instance_id          = aws_instance.vpn.id
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.premise.id
  }
}

resource "aws_route_table_association" "premise_private_a_rta" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_a.id
}

resource "aws_route_table_association" "premise_private_b_rta" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_b.id
}

# Allow ssh and icmp ping security group

resource "aws_security_group" "premise" {
  vpc_id = aws_vpc.premise.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
  }

  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    protocol    = "icmp"
    description = "Allow ICMP"
    from_port   = 8
    to_port     = 0
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    description = "Allow all outgoing"
    protocol    = "-1"
  }

  tags = {
    "Name" = "Allow SSH"
  }
}

resource "aws_security_group" "vpn" {
  vpc_id = aws_vpc.premise.id

  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    protocol    = "udp"
    description = "Custom UDP"
    from_port   = 53
    to_port     = 53
  }

  tags = {
    "Name" = "Allow VPN"
  }
}

# DHCP route, options and association

resource "aws_vpc_dhcp_options" "premise" {
  domain_name         = "premise.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "premise" {
  vpc_id          = aws_vpc.premise.id
  dhcp_options_id = aws_vpc_dhcp_options.premise.id
}