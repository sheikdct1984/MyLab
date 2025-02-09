

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "k8s-vnet"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = ["10.0.0.0/16"]
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "k8s-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group (NSG) for VMs
resource "azurerm_network_security_group" "nsg" {
  name                = "k8s_nsg"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IPs (optional, required for SSH access)
resource "azurerm_public_ip" "vm_pip" {
  count               = 3
  name                = "vm-pip-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  allocation_method   = "Dynamic"
}

# Network Interfaces (NICs)
resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "k8s-nic-${count.index}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[count.index].id
  }
}

# Attach NSG to NICs
resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = 3
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Linux Virtual Machines
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = {
    master-node = 0
    worker1     = 1
    worker2     = 2
  }

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic[each.value].id]

  # OS Disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Ubuntu 22.04 Image
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  disable_password_authentication = true

  # SSH Key Setup
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("./id_rsa.pub")  # Change this to your SSH key path
  }
}
