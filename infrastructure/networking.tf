// VPC for the subnet
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    ProjectTag = var.project_tag
  }
}

// Subnet for the instance
resource "aws_subnet" "subnet" {
  availability_zone       = var.availability_zone
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"

  tags = {
    ProjectTag = var.project_tag
  }
}

// Attach internet gateway to the VPC
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id

  // Points all traffic to the internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    ProjectTag = var.project_tag
  }
}

// Replaces the VPC main route table
resource "aws_main_route_table_association" "main_route_table_association" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route_table.id
}

// Firewall
resource "aws_security_group" "security_group" {
  name        = "allow_ssh_and_out_tcp"
  description = "Allow SSH and all ipv4 outbound TCP"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    ProjectTag = var.project_tag
  }

  lifecycle {
    create_before_destroy = true
  }
}

// Firewall rules:

// * Allow incoming TCP ipv4 traffic on port 22 (used by SSH)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

// * Allow incoming TCP ipv4 traffic on port 443 (used by HTTPS)
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

// * Allow incoming UDP ipv4 traffic on port 51820 (used by Wireguard)
resource "aws_vpc_security_group_ingress_rule" "wireguard" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 51820
  ip_protocol = "udp"
  to_port     = 51820
}

// * Allow all ipv4 outbound traffic on all ports
resource "aws_vpc_security_group_egress_rule" "all_ipv4_out" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1" // all ip protocols
}
