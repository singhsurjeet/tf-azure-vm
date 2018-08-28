

# Create a resource group
resource "azurerm_resource_group" "resource-group" {
  name     = "${var.environment}-resource-group"
  location = "${var.region}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "network" {
  name                = "${var.environment}-network"
  address_space       = ["${var.address_space}"]
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.resource-group.name}"

}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "${azurerm_resource_group.resource-group.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "${var.subnet1_cidr}"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = "${azurerm_resource_group.resource-group.name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix       = "${var.subnet2_cidr}"
}


