variable "name_prefix" {
  description = "Prefix used to name every resource, for example seclab-dev."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the network resources."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space of the virtual network. The first entry is split into /24 subnets."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "admin_source_ip_cidr" {
  description = "Public IP (with /32) allowed to reach the management subnet over SSH."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_source_ip_cidr, 0)) && var.admin_source_ip_cidr != "0.0.0.0/0"
    error_message = "Provide a valid CIDR such as 203.0.113.10/32. Opening SSH to the whole Internet (0.0.0.0/0) is not allowed."
  }
}

variable "tags" {
  description = "Tags applied to every resource."
  type        = map(string)
  default     = {}
}
