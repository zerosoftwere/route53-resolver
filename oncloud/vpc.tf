# VPC 10.10.0.0/16

resource "aws_vpc" "cloud" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "Cloud VPC"
  }
}

# Public subnet

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.cloud.id
  cidr_block              = "10.10.0.0/24"
  availability_zone       = "${var.REGION}a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Cloud Public a"
  }
}

# Private subnets

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.cloud.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "${var.REGION}b"

  tags = {
    "Name" = "Cloud Private b"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.cloud.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "${var.REGION}c"

  tags = {
    "Name" = "Cloud Private c"
  }
}

# Internet gateway, route table and route table association

resource "aws_internet_gateway" "cloud" {
  vpc_id = aws_vpc.cloud.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cloud.id

  tags = {
    "Name" = "Cloud public"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloud.id
  }

  lifecycle {
    ignore_changes = [
      propagating_vgws
    ]
  }
}

resource "aws_route_table_association" "cloud_public_rta" {
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.cloud.id

  tags = {
    "Name" = "Cloud private"
  }

  lifecycle {
    ignore_changes = [
      propagating_vgws
    ]
  }
}

resource "aws_route_table_association" "cloud_private_a_rta" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_a.id
}

resource "aws_route_table_association" "cloud_private_b_rta" {
  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private_b.id
}

# Allow ssh and ping security groups

resource "aws_security_group" "cloud" {
  vpc_id = aws_vpc.cloud.id

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
    "Name" = "Cloud"
  }

}

resource "aws_security_group" "dns_resolver" {
  vpc_id = aws_vpc.cloud.id

  ingress {
    cidr_blocks = ["10.0.0.0/8"]
    from_port   = 53
    to_port     = 53
    description = "Allow DNS Query"
    protocol    = "udp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    description = "Allow all outgoing"
  }

  tags = {
    "Name" = "DNS Resolver"
  }
}

# DHCP options and association

resource "aws_vpc_dhcp_options" "cloud" {
  domain_name         = "cloud.internal"
  domain_name_servers = ["AmazonProvidedDNS"]
}

resource "aws_vpc_dhcp_options_association" "cloud" {
  vpc_id          = aws_vpc.cloud.id
  dhcp_options_id = aws_vpc_dhcp_options.cloud.id
}