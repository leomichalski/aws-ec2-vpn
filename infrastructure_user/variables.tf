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
variable "region" {
  type        = string
  default     = "sa-east-1"
}
variable "project_tag" {
  type        = string
  default     = "my-vpn-tag"
}
variable "username" {
  type        = string
  default     = "my_vpn_infra_user"
}
variable "group_name" {
  type        = string
  default     = "my-vpn-infra-group"
}
variable "membership_name" {
  type        = string
  default     = "my-vpn-infra-manager-group"
}
variable "policies_path" {
  type        = string
  default     = "/my_vpn_infra/"
}
