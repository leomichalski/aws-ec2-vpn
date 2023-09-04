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
