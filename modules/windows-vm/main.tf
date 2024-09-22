data "http" "my_ip" {
  url = "http://icanhazip.com"
}

data "azurerm_virtual_network" "this" {
  name                = var.vnet
  resource_group_name = var.resource_group
}

data "azurerm_subnet" "this" {
  name                 = var.subnet
  virtual_network_name = var.vnet
  resource_group_name  = var.resource_group
}

resource "random_string" "password" {
  length           = 16
  special          = true
  override_special = "!-_."
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
}

resource "azurerm_network_interface" "primary" {
  name                = "${var.name}VM-nic"
  location            = data.azurerm_virtual_network.this.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  name                  = "${var.name}VM"
  resource_group_name   = var.resource_group
  location              = data.azurerm_virtual_network.this.location
  size                  = var.vm_size
  admin_username        = var.username
  admin_password        = random_string.password.result
  network_interface_ids = [azurerm_network_interface.primary.id]

  os_disk {
    caching              = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_public_ip" "this" {
  name                = "${var.name}-IP"
  resource_group_name = var.resource_group
  location            = data.azurerm_virtual_network.this.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.name}-NSG"
  location            = data.azurerm_virtual_network.this.location
  resource_group_name = var.resource_group

  security_rule {
    name                       = "default-allow-rdp"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "${chomp(data.http.my_ip.response_body)}/32"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  subnet_id                 = data.azurerm_subnet.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}