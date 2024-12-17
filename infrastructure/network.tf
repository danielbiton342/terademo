//resource group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.rg-location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.resource_group}-${var.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
// db subnet
resource "azurerm_subnet" "db_subnet" {
  name                 = "snet-db-dev-${var.location}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
// db nsg
resource "azurerm_network_security_group" "db-nsg" {
  name                = "nsg-db-dev-${var.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow_app_vm_access"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"                                          # Assuming PostgreSQL on the database VM
    source_address_prefix      = azurerm_subnet.flask_subnet.address_prefixes[0] # Allow access from app VM subnet
    destination_address_prefix = "10.0.2.0/24"
  }
  security_rule {
    name                       = "allow_bastion_access"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "10.0.3.0/27"
    destination_address_prefix = "10.0.2.0/24"
  }
}
//app subnet
resource "azurerm_subnet" "flask_subnet" {
  name                 = "snet-flask-dev-${var.location}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
// app flask nsg
resource "azurerm_network_security_group" "flask-nsg" {
  name                = "nsg-flask-dev-${var.location}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }
  security_rule {
    name                       = "AllowSSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }
  security_rule {
    name                       = "Allow-Postgres"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "10.0.2.0/24"
    destination_address_prefix = "10.0.1.0/24"
  }
}
//db nic
resource "azurerm_network_interface" "db-nic" {
  name                = "nic-dev-db-${var.resource_group}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.db_subnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
  }
}
// association of nsg and nic DB
resource "azurerm_network_interface_security_group_association" "db-nic-nsg-association" {
  network_interface_id      = azurerm_network_interface.db-nic.id
  network_security_group_id = azurerm_network_security_group.db-nsg.id
}
// association of nsg and subnet DB
resource "azurerm_subnet_network_security_group_association" "db-subnet-nsg-association" {
  network_security_group_id = azurerm_network_security_group.db-nsg.id
  subnet_id                 = azurerm_subnet.db_subnet.id
}
// public ip
resource "azurerm_public_ip" "vm_publicIP" {
  name                = "pip-dev-flask-${var.location}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Development"
  }
}
// flask vm nic
resource "azurerm_network_interface" "flask-nic" {
  name                = "nic-dev-flask-${var.resource_group}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.flask_subnet.id
    private_ip_address_allocation = "Dynamic"
    primary                       = true
    public_ip_address_id          = azurerm_public_ip.vm_publicIP.id
  }
}
// association of nsg and subnet flask VM
resource "azurerm_subnet_network_security_group_association" "flask-subnet-nsg-association" {
  network_security_group_id = azurerm_network_security_group.flask-nsg.id
  subnet_id                 = azurerm_subnet.flask_subnet.id
}
// association of nsg + nic for flask vm
resource "azurerm_network_interface_security_group_association" "flask-nic-nsg-association" {
  network_interface_id      = azurerm_network_interface.flask-nic.id
  network_security_group_id = azurerm_network_security_group.flask-nsg.id
}

