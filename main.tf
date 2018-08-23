# Configure the Azure Provider
provider "azurerm" { }

module "cluster" {
  source = "modules/k8s-cluster"

  region = "${var.region}"

}