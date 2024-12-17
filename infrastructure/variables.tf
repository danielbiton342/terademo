variable "resource_group" {
  type    = string
  default = "terademo"
}
variable "rg-location" {
  type    = string
  default = "Central US"
}

variable "VM_USER" {
  type = string
}

variable "VM_PASSWORD" {
  type      = string
  sensitive = true
}

variable "my_publicIP" {
  type = string
}

variable "DB_USER" {
  type = string
}

variable "DB_PASSWORD" {
  type      = string
  sensitive = true
}
