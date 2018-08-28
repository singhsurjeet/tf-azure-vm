
resource "azurerm_public_ip" "publicIP" {
  count                        = "${var.vm-count}"
  name                         = "publicIPworker-${count.index}"
  location                     = "${var.region}"
  resource_group_name          = "${var.rsg}"
  public_ip_address_allocation = "dynamic"
}

resource "azurerm_network_security_group" "sg" {
  name = "worker-sg"
  location = "${var.region}"
  resource_group_name = "${var.rsg}"
}

resource "azurerm_network_security_rule" "ssh-inbound"  {
  name                       = "SSH-inbound"
  priority                   = 1001
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "22"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = "${var.rsg}"
  network_security_group_name  = "${azurerm_network_security_group.sg.name}"
}


resource "azurerm_network_interface" "nic" {
  count                         = "${var.vm-count}"
  name                          = "nic-worker-${count.index}"
  location                      = "${var.region}"
  resource_group_name           = "${var.rsg}"
  network_security_group_id     = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "nic-worker"
    subnet_id                     = "${var.subnet1}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id ="${length(azurerm_public_ip.publicIP.*.id) > 0 ? element(concat(azurerm_public_ip.publicIP.*.id, list("")), count.index) : ""}"
  }

}

resource "random_id" "randomId" {
  count = "${var.vm-count}"
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.rsg}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
  count                     = "${var.vm-count}"
  name                      = "diag${length(random_id.randomId.*.hex) > 0 ? element(concat(random_id.randomId.*.hex, list("")), count.index) : ""}"
  resource_group_name       = "${var.rsg}"
  location                  = "${var.region}"
  account_replication_type  = "LRS"
  account_tier              = "Standard"
}

resource "azurerm_virtual_machine" "vm" {
  count                   = "${var.vm-count}"
  name                    = "worker-vm-${count.index}"
  location                = "${var.region}"
  resource_group_name     = "${var.rsg}"
  network_interface_ids   = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size                 = "${var.vm-size}"
  delete_os_disk_on_termination = true

  storage_os_disk {
    name = "OsDisk-worker-${count.index}"
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
    computer_name = "worker-${count.index}"
    admin_username = "azureuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${var.ssh-key}"  }
  }

  boot_diagnostics {
    enabled = "true"
    storage_uri = "${length(azurerm_storage_account.storageaccount.*.primary_blob_endpoint) > 0 ? element(concat(azurerm_storage_account.storageaccount.*.primary_blob_endpoint, list("")), count.index) : ""}"
  }
}

