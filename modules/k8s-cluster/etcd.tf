
resource "azurerm_public_ip" "publicIPetcd" {
  name                         = "publicIPetcd"
  location                     = "${var.region}"
  resource_group_name          = "${azurerm_resource_group.dev-group.name}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_security_group" "etcd-sg" {
  name                = "etcd-sg"
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

resource "azurerm_network_interface" "nic-etcd" {
  count               = 1
  name                = "nic-etcd"
  location            = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-group.name}"

  ip_configuration {
    name                          = "nic-etcd"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicIPetcd.id}"
  }

}

resource "random_id" "randomId-etcd" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.dev-group.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "storageaccount-etcd" {
  name                = "diag${random_id.randomId-etcd.hex}"
  resource_group_name = "${azurerm_resource_group.dev-group.name}"
  location            = "${var.region}"
  account_replication_type = "LRS"
  account_tier = "Standard"
}

resource "azurerm_virtual_machine" "etcd-vm" {
  name = "etcd-vm"
  location = "${var.region}"
  resource_group_name = "${azurerm_resource_group.dev-group.name}"
  network_interface_ids = [
    "${azurerm_network_interface.nic-etcd.id}"]
  vm_size = "Standard_B1s"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name = "OsDisk-etcd"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Premium_LRS"
  }


  storage_image_reference {
    publisher = "RedHat"
    offer = "RHEL"
    sku = "7.3"
    version = "latest"
  }

  os_profile {
    computer_name = "etcd"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKIxn1R7jKSYzJUOHG1UeVTQ406uLVgnwe8GrlbH54Y/+2evhH94W5Z1Vqb5SKiSC7NfrtO2TbAglgAH7/iIkX/VbUQmubKGoSIgwjHsjCWtHgedh69q7HEuXqfOhRJ0CheUa0abCDYN8cEdABDaODiZpQi1RMWDiHeCL37u9WmdesYX2oukodZerNioqcIyu9WTA6I60EBGWXPcqTZLCDnxcJIQntAAOu/AHPOKsn+t7nX33EwzSaSDTZCE6Nfmz2jr7eVMSzbKulz4ohIY1s5Vm4a0HyNWF6XKRiRMDzXFvH3CfwqzpOpXzRZuIkt+GO/UHFuTNdwNTFs9dmsE7R sursingh10@WKMGB0869902"
    }
  }

  boot_diagnostics {
    enabled = "true"
    storage_uri = "${azurerm_storage_account.storageaccount-etcd.primary_blob_endpoint}"
  }
}