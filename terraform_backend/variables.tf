variable "aws_access_key" {
  type        = string
  sensitive   = true // still accessible in the state data
}
variable "aws_secret_key" {
  type        = string
  sensitive   = true // still accessible in the state data
}
variable "aws_session_token" {
  type        = string
  sensitive   = true // still accessible in the state data
}
variable "s3_backend_bucket" {
  type        = string
  default     = "my-vpn-terraform-state"
}
variable "s3_backend_key_path" {
  description = "The Terraform state is written to the key path/to/my/key."
  type        = string
  default     = "network/terraform.tfstate"
}
variable "s3_backend_dynamodb_table" {
  type        = string
  default     = "my-vpn-terraform-state-lock"
}
variable "dynamodb_table_provisioned_rcu" {
  description = "Free tier: 25 provisioned Read Capacity Units (RCU)"
  type        = number
  default     = 20
}
variable "dynamodb_table_provisioned_wcu" {
  description = "Free tier: 25 provisioned Write Capacity Units (WCU)"
  type        = number
  default     = 20
}
variable "region" {
  type        = string
  default     = "sa-east-1"
}
variable "project_tag" {
  type        = string
  default     = "my-vpn-tag"
}
variable "backend_conf_file_name" {
  type        = string
  default     = "backend.conf"
}
variable "backend_conf_file_permission" {
  type        = string
  default     = "0644"
}
