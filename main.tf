# Configure the Azure Provider
provider "azurerm" { }

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

resource "azurerm_public_ip" "publicIP1" {
  name                         = "publicIP1"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.dev-group.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_security_group" "master-sg" {
  name                = "master-sg"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-group.name}"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "NIC"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-group.name}"

  ip_configuration {
    name                          = "NicConfiguration"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicIP1.id}"
  }

}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.dev-group.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
  name                = "diag${random_id.randomId.hex}"
  resource_group_name = "${azurerm_resource_group.dev-group.name}"
  location            = "${var.region}"
  account_replication_type = "LRS"
  account_tier = "Standard"
}

resource "azurerm_virtual_machine" "vm1" {
  name                  = "VM1"
  location              = "${var.region}"
  resource_group_name   = "${azurerm_resource_group.dev-group.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "Standard_B1ms"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "OsDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }


  storage_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "7.3"
    version   = "latest"
  }

  os_profile {
    computer_name  = "vm1"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKIxn1R7jKSYzJUOHG1UeVTQ406uLVgnwe8GrlbH54Y/+2evhH94W5Z1Vqb5SKiSC7NfrtO2TbAglgAH7/iIkX/VbUQmubKGoSIgwjHsjCWtHgedh69q7HEuXqfOhRJ0CheUa0abCDYN8cEdABDaODiZpQi1RMWDiHeCL37u9WmdesYX2oukodZerNioqcIyu9WTA6I60EBGWXPcqTZLCDnxcJIQntAAOu/AHPOKsn+t7nX33EwzSaSDTZCE6Nfmz2jr7eVMSzbKulz4ohIY1s5Vm4a0HyNWF6XKRiRMDzXFvH3CfwqzpOpXzRZuIkt+GO/UHFuTNdwNTFs9dmsE7R sursingh10@WKMGB0869902"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.storageaccount.primary_blob_endpoint}"
  }
}