variable "region" {}

variable "rsg" {}

variable "environment" {}

variable "subnet1" {}

variable "ssh-key" {}

variable "vm-size" {}

variable "vm-count" {}

variable "boot_diagnostics" {
  default = true
}