/*
Azure Variables
*/

variable "az_resource_group_name" {
  description = "Name of the azure resource group"
  type        = string
}

variable "az_location" {
  description = "Azure region for resources"
}

variable "public_ip_address" {
  description = "Public IP address for dev"
}