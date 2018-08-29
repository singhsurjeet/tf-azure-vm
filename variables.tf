variable "region" {
  default = "ukwest"
}

variable "address_space" {
  default = "10.0.0.0/16"
}

variable "environment" {
  default = "dev"
}

variable "subnet1_cidr" {
   default = "10.0.1.0/24"
 }

variable "subnet2_cidr" {
  default = "10.0.2.0/24"
}

variable "subnet_names" {
  description = "A list of public subnets inside the vNet."
  type = "list"
  default     = ["subnet1","subnet2"]
}

variable "ssh-public-key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "vmsize-master" {
  default = "Standard_B1ms"
}

variable "vmsize-worker" {
  default = "Standard_B1s"
}

variable "vmsize-etcd" {
  default = "Standard_B1s"
}