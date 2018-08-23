

# Create a resource group
resource "azurerm_resource_group" "dev-group" {
  name     = "dev-group"
  location = "${var.region}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "dev-network" {
  name                = "dev-network"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-group.name}"

}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "${azurerm_resource_group.dev-group.name}"
  virtual_network_name = "${azurerm_virtual_network.dev-network.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = "${azurerm_resource_group.dev-group.name}"
  virtual_network_name = "${azurerm_virtual_network.dev-network.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "subnet3" {
  name                 = "subnet3"
  resource_group_name  = "${azurerm_resource_group.dev-group.name}"
  virtual_network_name = "${azurerm_virtual_network.dev-network.name}"
  address_prefix       = "10.0.3.0/24"
}


