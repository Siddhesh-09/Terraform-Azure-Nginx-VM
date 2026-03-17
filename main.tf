terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.64.0"
    }
  }
}

provider "azurerm" {
    features {
      
    }
    subscription_id = "22a23b40-2d6e-4fd2-8f33-ae9291dae00f"
  
}

resource "azurerm_resource_group" "rg-terraform" {
  name     = "rg-terraform"
  location = "centralindia"
  
}

resource "azurerm_virtual_network" "vnet-terraform" {
  name                = "vnet-terraform"
  address_space       = ["125.72.64.0/18"]
  location            = azurerm_resource_group.rg-terraform.location
  resource_group_name = azurerm_resource_group.rg-terraform.name
  
}

resource "azurerm_subnet" "dev-subnet" {
  name                 = "dev-subnet"
  virtual_network_name = azurerm_virtual_network.vnet-terraform.name
  resource_group_name  = azurerm_resource_group.rg-terraform.name
  address_prefixes     = ["125.72.85.0/24"]
}

resource "azurerm_network_security_group" "nsg-terraform" {
  name                = "nsg-terraform"
  location            = azurerm_resource_group.rg-terraform.location
  resource_group_name = azurerm_resource_group.rg-terraform.name
  
  security_rule  {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule  {
    name                       = "HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_public_ip" "mypublicip" {
  name                = "mypublicip"
  location            = azurerm_resource_group.rg-terraform.location
  resource_group_name = azurerm_resource_group.rg-terraform.name
  allocation_method   = "Static"
  
}

resource "azurerm_network_interface" "nic-terraform" {
  name                = "nic-terraform"
  location            = azurerm_resource_group.rg-terraform.location
  resource_group_name = azurerm_resource_group.rg-terraform.name 
  
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.dev-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublicip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_interface_id      = azurerm_network_interface.nic-terraform.id
  network_security_group_id = azurerm_network_security_group.nsg-terraform.id
  
}

resource "azurerm_linux_virtual_machine" "vm-terraform" {
  name                = "vm-terraform"
  location            = azurerm_resource_group.rg-terraform.location
  resource_group_name = azurerm_resource_group.rg-terraform.name
  size                = "Standard_D2ads_v6"
  admin_username      = "azureuser"
  admin_password      = "Password@123"
  disable_password_authentication = false
  network_interface_ids = [azurerm_network_interface.nic-terraform.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "ssh_command" {
    value = "ssh azureuser@${azurerm_public_ip.mypublicip.ip_address}"
    description = "SSH command to connect to the VM"
  
}
