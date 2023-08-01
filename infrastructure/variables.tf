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
