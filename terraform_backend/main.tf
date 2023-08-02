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

resource "local_file" "backend_configuration" {
  filename        = var.backend_conf_file_name
  file_permission = var.backend_conf_file_permission
  content         = <<-EOT
    bucket="${var.s3_backend_bucket}"
    key="${var.s3_backend_key_path}"
    region="${var.region}"
    encrypt=true
    dynamodb_table="${var.s3_backend_dynamodb_table}"
  EOT
}
