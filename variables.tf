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
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKIxn1R7jKSYzJUOHG1UeVTQ406uLVgnwe8GrlbH54Y/+2evhH94W5Z1Vqb5SKiSC7NfrtO2TbAglgAH7/iIkX/VbUQmubKGoSIgwjHsjCWtHgedh69q7HEuXqfOhRJ0CheUa0abCDYN8cEdABDaODiZpQi1RMWDiHeCL37u9WmdesYX2oukodZerNioqcIyu9WTA6I60EBGWXPcqTZLCDnxcJIQntAAOu/AHPOKsn+t7nX33EwzSaSDTZCE6Nfmz2jr7eVMSzbKulz4ohIY1s5Vm4a0HyNWF6XKRiRMDzXFvH3CfwqzpOpXzRZuIkt+GO/UHFuTNdwNTFs9dmsE7R sursingh10@WKMGB0869902"
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