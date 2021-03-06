
resource "azurerm_public_ip" "publicIP" {
  name                         = "publicIPetcd"
  location                     = "${var.region}"
  resource_group_name          = "${var.rsg}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_security_group" "sg" {
  name = "etcd-sg"
  location = "${var.region}"
  resource_group_name = "${var.rsg}"
}

resource "azurerm_network_security_rule" "all-inbound"  {
  name                       = "all-inbound"
  priority                   = 1001
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = "${var.rsg}"
  network_security_group_name  = "${azurerm_network_security_group.sg.name}"
}

resource "azurerm_network_security_rule" "all-outbound"  {
  name                       = "all-outbound"
  priority                   = 1001
  direction                  = "Outbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
  resource_group_name        = "${var.rsg}"
  network_security_group_name  = "${azurerm_network_security_group.sg.name}"
}


resource "azurerm_network_interface" "nic" {
  count               = 1
  name                = "nic-etcd"
  location            = "${var.region}"
  resource_group_name = "${var.rsg}"
  network_security_group_id     = "${azurerm_network_security_group.sg.id}"

  ip_configuration {
    name                          = "nic-etcd"
    subnet_id                     = "${var.subnet1}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.publicIP.id}"
  }

}

resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${var.rsg}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "storageaccount" {
  name                = "diag${random_id.randomId.hex}"
  resource_group_name = "${var.rsg}"
  location            = "${var.region}"
  account_replication_type = "LRS"
  account_tier = "Standard"
}


data "template_file" "cloudconfig" {
  template = "${file("${path.module}/cloudconfig.sh")}"
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.cloudconfig.rendered}"
  }
}


resource "azurerm_virtual_machine" "vm" {
  count = "${var.vm-count}"
  name = "etcd-vm"
  location = "${var.region}"
  resource_group_name = "${var.rsg}"
  network_interface_ids = [
    "${azurerm_network_interface.nic.id}"]
  vm_size = "${var.vm-size}"
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
    custom_data    = "${data.template_cloudinit_config.config.rendered}"}

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/azureuser/.ssh/authorized_keys"
      key_data = "${file("${var.ssh-key}")}"
    }
  }

  boot_diagnostics {
    enabled = "true"
    storage_uri = "${azurerm_storage_account.storageaccount.primary_blob_endpoint}"
  }
}

