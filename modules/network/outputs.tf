
output "rsg" {
  value = "${azurerm_resource_group.resource-group.name}"
}

output "subnet1" {
  value = "${azurerm_subnet.subnet1.id}"
}

output "subnet2" {
  value = "${azurerm_subnet.subnet2.id}"
}

output "vnet" {
  value = "${azurerm_virtual_network.network.id}"
}