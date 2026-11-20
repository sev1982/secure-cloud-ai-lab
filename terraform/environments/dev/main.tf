locals {
  name_prefix = "${var.project}-${var.environment}"

  tags = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "network" {
  name     = "rg-${local.name_prefix}-network"
  location = var.location
  tags     = local.tags
}

module "network" {
  source = "../../modules/network"

  name_prefix          = local.name_prefix
  location             = var.location
  resource_group_name  = azurerm_resource_group.network.name
  admin_source_ip_cidr = var.admin_source_ip_cidr
  tags                 = local.tags
}
