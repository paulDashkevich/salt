variable "ah_token" {
  type        = string
  description = "Your access token in AH"
}

variable "ah_dc" {
  type        = string
  description = "Data Center Advanced Hosting"
}

variable "ah_image_type" {
  type        = string
  description = "which image to use"
}

variable "ah_machine_type" {
  type        = string
  description = "chose pricing plan and hardware"
}

variable "private_key_path" {
  type        = string
  description = "path to private key ssh"
}

variable "ah_hdd" {
  type        = string
  description = "type of hdd"
}

variable "ah_fp" {
  type        = string
  description = "your ssh-key hash"
}