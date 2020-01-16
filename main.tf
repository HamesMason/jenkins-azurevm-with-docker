################################################
# Testing Infrastructure for Terraform Modules #
################################################

### General

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}


### Network

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.virtual_network_name}"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.subnet_name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "10.0.0.0/24"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
}

resource "azurerm_public_ip" "pip" {
  name                         = "${var.public_ip_name}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  public_ip_address_allocation = "Static"
  domain_name_label            = "${var.public_domain_name}"
}

resource "azurerm_network_security_group" "allows" {
  name = "${var.network_security_group_name}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "AllowSshInBound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowhttpjenkinsInBound"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowhttpInBound"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowHttpsInBound"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  name                      = "${var.network_interface_name}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.allows.id}"

  ip_configuration {
    name                          = "${var.network_interface_name}-configuration"
    subnet_id                     = "${azurerm_subnet.subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }
}


### Virtual Machine

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.virtual_machine_name}"
  location              = "${azurerm_resource_group.rg.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]
  vm_size               = "${var.virtual_machine_size}"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.virtual_machine_osdisk_name}"
    create_option     = "FromImage"
    managed_disk_type = "${var.virtual_machine_osdisk_type}"
  }

  os_profile {
    computer_name  = "${var.virtual_machine_computer_name}"
    admin_username = "${var.admin_username}"
    admin_password = "Password1234!"
}

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type        = "ssh"
    host        = "${azurerm_public_ip.pip.ip_address}"
    user        = "${var.admin_username}"
    password = "Password1234!"
  }

  provisioner "file" {
  source      = "Dockerfile"
  destination = "Dockerfile"
}

provisioner "file" {
  source      = "sample.war"
  destination = "sample.war"
}

  provisioner "remote-exec" {
    inline = [
      # Build Essentials
      "sudo apt-get update",
      "sudo apt-get install build-essential -y",
      "sudo apt-get install unzip -y",
      "sudo apt-get install make -y",
      "sudo apt-get install openjdk-8-jdk openjdk-8-jre -y",
      "sudo apt-get install git maven docker.io -y",
      "sudo docker build -t app:0.0.1 .",
      "sudo docker run -d -p 8080:8080 app:0.0.1",
    ]
  }
}
