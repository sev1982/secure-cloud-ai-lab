output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by zone (mgmt, security, workloads, dmz)."
  value       = { for zone, subnet in azurerm_subnet.this : zone => subnet.id }
}

output "subnet_cidrs" {
  description = "CIDR block of each zone."
  value       = local.subnet_cidrs
}
