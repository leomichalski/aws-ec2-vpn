variable "aws_access_key" {
  type      = string
  sensitive = true // still accessible in the state data
}
variable "aws_secret_key" {
  type      = string
  sensitive = true // still accessible in the state data
}
variable "aws_session_token" {
  type      = string
  sensitive = true // still accessible in the state data
}
variable "default_ssh_key_name" {
  type      = string
  sensitive = true // still accessible in the state data
}
variable "default_ssh_public_key" {
  type      = string
  sensitive = true // still accessible in the state data
}
variable "region" {
  type      = string
  default   = "sa-east-1"
}
variable "availability_zone" {
  type      = string
  default   = "sa-east-1a" // aws ec2 describe-availability-zones --region sa-east-1
}
variable "project_tag" {
  type      = string
  default   = "my-vpn-tag"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

// Operating System
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-amd64-minimal-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"] // Canonical
}

// Basic ipv4 VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    ProjectTag = var.project_tag
  }
}

resource "aws_subnet" "subnet" {
  availability_zone       = var.availability_zone
  // map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"

  tags = {
    ProjectTag = var.project_tag
  }
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

// Allow incoming TCP ipv4 traffic on port 22 (used by SSH)
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

// Allow incoming TCP ipv4 traffic on port 443 (used by HTTPS)
resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

// Allow incoming UDP ipv4 traffic on port 51820 (used by Wireguard)
resource "aws_vpc_security_group_ingress_rule" "wireguard" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 51820
  ip_protocol = "udp"
  to_port     = 51820
}

// Allow all ipv4 outbound traffic on all ports
resource "aws_vpc_security_group_egress_rule" "all_ipv4_out" {
  security_group_id = aws_security_group.security_group.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1" // all ip protocols
}

// Copy public key to AWS
resource "aws_key_pair" "default_ssh" {
  key_name   = var.default_ssh_key_name
  public_key = var.default_ssh_public_key

  tags = {
    ProjectTag = var.project_tag
  }
}

// EC2 Instance
resource "aws_instance" "instance" {
  ami                                  = data.aws_ami.ubuntu.id
  associate_public_ip_address          = true
  availability_zone                    = var.availability_zone
  subnet_id                            = aws_subnet.subnet.id
  // Copy public key to instance
  key_name                             = aws_key_pair.default_ssh.key_name
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.micro"
  monitoring                           = false
  vpc_security_group_ids               = [aws_security_group.security_group.id]


  // Keeps volume when terminated, doesn't reattach when recreated
  root_block_device {
    delete_on_termination = false
    encrypted             = false
    volume_size           = 10 // GiB
    volume_type           = "gp2"
  }
  tags = {
    ProjectTag = var.project_tag
  }
}

output "instance_public_ip" {
  value = aws_instance.instance.public_ip
}
output "instance_public_dns" {
  value = aws_instance.instance.public_dns
}
