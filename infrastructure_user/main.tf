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

// Create Terraform user
resource "aws_iam_user" "user" {
  name = var.username
  force_destroy = true

  tags = {
    ProjectTag = var.project_tag
  }
}

// Create a Terraform group for managing the infrastructure
resource "aws_iam_group" "group" {
  name = var.group_name
}

// Assign Terraform user to the group
resource "aws_iam_group_membership" "membership" {
  name = var.membership_name

  users = [
    aws_iam_user.user.name,
  ]

  group = aws_iam_group.group.name
}

// Provides an IAM access key for the user
resource "aws_iam_access_key" "terraform_access_key" {
  user = aws_iam_user.user.name
}

// Outputs access key ID
output "AWS_ACCESS_KEY_ID" {
  value = aws_iam_access_key.terraform_access_key.id
}

// Outputs secret access key
output "AWS_SECRET_ACCESS_KEY" {
  # sensitive = true
  value = nonsensitive(aws_iam_access_key.terraform_access_key.secret)
}
