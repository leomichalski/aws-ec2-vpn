// More backend options:
// https://developer.hashicorp.com/terraform/language/settings/backends/configuration

// Create S3 bucket for storing the state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = var.s3_backend_bucket
  force_destroy = true

  tags = {
    ProjectTag = var.project_tag
  }
}

// Create DynamoDB table for state locking
resource "aws_dynamodb_table" "terraform_state_lock" {
  name = var.s3_backend_dynamodb_table
  read_capacity = var.dynamodb_table_provisioned_rcu
  write_capacity = var.dynamodb_table_provisioned_wcu
  # deletion_protection_enabled = true

  // The table must have a partition key named LockID with type of String.
  // If not configured, state locking will be disabled.
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S" // S (string), N (number), B (binary)
  }

  tags = {
    ProjectTag = var.project_tag
  }
}
