variable "location" {
  type    = string
  default = "centralus"
}

// reference for the created public IP 
data "azurerm_public_ip" "vm_publicIP" {
  name                = azurerm_public_ip.vm_publicIP.name
  resource_group_name = azurerm_resource_group.rg.name
}

// ssh key for tls
resource "tls_private_key" "flaskvm-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "flaskvm_public_key" {
  filename = "${path.module}\\flaskvm_key.pem"
  content  = tls_private_key.flaskvm-ssh.private_key_pem
}

// application vm
resource "azurerm_linux_virtual_machine" "flask-vm" {
  name                = "vm-dev-flask-${var.location}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = var.VM_USER
  network_interface_ids = [
    azurerm_network_interface.flask-nic.id,
  ]

  # OS disk configuration
  os_disk {
    name                 = "flask_os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image reference for the VM
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  computer_name                   = var.VM_USER
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.VM_USER
    public_key = tls_private_key.flaskvm-ssh.public_key_openssh
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y python3-pip",
      "sudo pip install Flask",
      "sudo pip install psycopg2-binary",
      "sudo apt install git -y",
      "sudo apt-get install -y postgresql-client",
      "pip install python-dotenv"
    ]
    # Connection details for SSH
    connection {
      type        = "ssh"
      host        = data.azurerm_public_ip.vm_publicIP.ip_address
      user        = var.VM_USER
      private_key = tls_private_key.flaskvm-ssh.private_key_openssh
    }
  }
  depends_on = [azurerm_subnet_network_security_group_association.flask-subnet-nsg-association]
}

// commands to execute in the vm
resource "azurerm_virtual_machine_extension" "flask-vm-Extensions" {
  name                 = "flaskvm-extension-${var.location}"
  virtual_machine_id   = azurerm_linux_virtual_machine.flask-vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
  {
    "commandToExecute": "git clone https://github.com/danielbiton342/flask-psql.git /home/${var.VM_USER}/flask-psql"
  }
SETTINGS

  tags = {
    environment = "development"
  }
}

/*
// ssh key for tls DB 
resource "tls_private_key" "db-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "db_public_key" {
  filename = "${path.module}\\db_key.pem"
  content  = tls_private_key.db-ssh.private_key_pem
}
*/

// db
resource "azurerm_linux_virtual_machine" "db-vm" {
  name                = "vm-dev-db-${var.location}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = var.DB_USER
  network_interface_ids = [
    azurerm_network_interface.db-nic.id,
  ]

  # OS disk configuration
  os_disk {
    name                 = "db_os_disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image reference for the VM
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  computer_name                   = var.DB_USER
  disable_password_authentication = false
  admin_password                  = var.VM_PASSWORD
}

