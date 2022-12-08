variable "REGION" {
  description = "AWS Region"
  default     = "us-east-2"
  type        = string
}

variable "KEY_PATH" {
  description = "SSH key path"
  type        = string
  default     = "sshkey.pub"
}