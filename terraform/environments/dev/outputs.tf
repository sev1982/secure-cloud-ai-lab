output "subnet_cidrs" {
  description = "CIDR block of each zone."
  value       = module.network.subnet_cidrs
}

output "vnet_id" {
  description = "ID of the virtual network."
  value       = module.network.vnet_id
}
