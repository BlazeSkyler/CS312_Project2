variable "public_key" {
  description = "Public key used to connect to EC2 instance"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}