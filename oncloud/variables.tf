variable "REGION" {
  description = "AWS Region"
  default     = "us-east-1"
  type        = string
}

variable "KEY_PATH" {
  description = "SSH key path"
  type        = string
  default     = "sshkey.pub"
}

variable "ON_PREMISE_VPN_IP" {
  description = "On premise vpn ip addresss"
  type        = string
}