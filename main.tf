# Configure the Azure Provider
provider "azurerm" { }

module "network" {
  source = "modules/network"

  region          = "${var.region}"
  address_space   = "${var.address_space}"
  environment     = "${var.environment}"
  subnet_names    = "${var.subnet_names}"
  subnet1_cidr    = "${var.subnet1_cidr}"
  subnet2_cidr    = "${var.subnet2_cidr}"

}

module "master" {
  source = "modules/master"

  region          = "${var.region}"
  environment     = "${var.environment}"
  rsg             = "${module.network.rsg}"
  subnet1         = "${module.network.subnet1}"
  ssh-key         = "${var.ssh-public-key}"
  vm-size         = "${var.vmsize-master}"
}

module "etcd" {
  source = "modules/etcd"

  region          = "${var.region}"
  environment     = "${var.environment}"
  rsg             = "${module.network.rsg}"
  subnet1         = "${module.network.subnet1}"
  ssh-key         = "${var.ssh-public-key}"
  vm-size         = "${var.vmsize-etcd}"
}

module "worker" {
  source = "modules/worker"

  vm-count        = 2
  region          = "${var.region}"
  environment     = "${var.environment}"
  rsg             = "${module.network.rsg}"
  subnet1         = "${module.network.subnet1}"
  ssh-key         = "${var.ssh-public-key}"
  vm-size         = "${var.vmsize-etcd}"
}
