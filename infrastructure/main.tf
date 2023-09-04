terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region     = var.region
}

// Copy public SSH key from local machine to AWS
resource "aws_key_pair" "default_ssh" {
  key_name   = var.default_ssh_key_name
  public_key = var.default_ssh_public_key

  tags = {
    ProjectTag = var.project_tag
  }
}

// EC2 Instance
resource "aws_instance" "instance" {
  ami                                  = data.aws_ami.operating_system.id
  instance_initiated_shutdown_behavior = "stop"
  instance_type                        = "t2.micro"
  monitoring                           = false
  vpc_security_group_ids               = [aws_security_group.security_group.id]
  depends_on                           = [aws_internet_gateway.internet_gateway]
  associate_public_ip_address          = true
  availability_zone                    = var.availability_zone
  subnet_id                            = aws_subnet.subnet.id
  // Copy public SSH key from AWS to the EC2 instance
  key_name                             = aws_key_pair.default_ssh.key_name

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
