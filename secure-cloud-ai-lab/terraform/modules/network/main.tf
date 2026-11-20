locals {
  # Each zone gets one /24 carved out of the VNet address space.
  # With 10.10.0.0/16: mgmt = 10.10.1.0/24, security = 10.10.2.0/24, and so on.
  subnet_index = {
    mgmt      = 1
    security  = 2
    workloads = 3
    dmz       = 4
  }

  subnet_cidrs = {
    for zone, index in local.subnet_index :
    zone => cidrsubnet(var.vnet_address_space[0], 8, index)
  }

  # Ports used by Wazuh agents to talk to the Wazuh server.
  wazuh_agent_ports = ["1514", "1515"]

  # Inbound rules, evaluated by priority (lowest number first).
  allow_rules = {
    "mgmt-allow-ssh-from-admin" = {
      nsg         = "mgmt"
      priority    = 100
      sources     = [var.admin_source_ip_cidr]
      ports       = ["22"]
      description = "SSH from the administrator public IP only"
    }
    "security-allow-wazuh-agents" = {
      nsg         = "security"
      priority    = 100
      sources     = [local.subnet_cidrs["dmz"], local.subnet_cidrs["workloads"], local.subnet_cidrs["mgmt"]]
      ports       = local.wazuh_agent_ports
      description = "Wazuh agent events and enrollment"
    }
    "security-allow-dashboard-from-mgmt" = {
      nsg         = "security"
      priority    = 110
      sources     = [local.subnet_cidrs["mgmt"]]
      ports       = ["443"]
      description = "Wazuh dashboard from the management subnet"
    }
    "security-allow-ssh-from-mgmt" = {
      nsg         = "security"
      priority    = 120
      sources     = [local.subnet_cidrs["mgmt"]]
      ports       = ["22"]
      description = "Administration from the management subnet"
    }
    "workloads-allow-admin-from-mgmt" = {
      nsg         = "workloads"
      priority    = 100
      sources     = [local.subnet_cidrs["mgmt"]]
      ports       = ["22", "3389"]
      description = "SSH and RDP from the management subnet"
    }
    "dmz-allow-https-from-internet" = {
      nsg         = "dmz"
      priority    = 100
      sources     = ["Internet"]
      ports       = ["443"]
      description = "Public web app over HTTPS"
    }
    "dmz-allow-ssh-from-mgmt" = {
      nsg         = "dmz"
      priority    = 110
      sources     = [local.subnet_cidrs["mgmt"]]
      ports       = ["22"]
      description = "Administration from the management subnet"
    }
  }

  # One explicit deny-all rule per zone. Azure's built-in rules allow all traffic
  # inside a VNet (priority 65000), so without this rule the DMZ could reach the workloads.
  deny_rules = {
    for zone in keys(local.subnet_index) :
    "${zone}-deny-all-inbound" => {
      nsg         = zone
      priority    = 4096
      sources     = ["*"]
      ports       = ["*"]
      description = "Default deny"
    }
  }

  nsg_rules = merge(
    { for name, rule in local.allow_rules : name => merge(rule, { access = "Allow", protocol = "Tcp" }) },
    { for name, rule in local.deny_rules : name => merge(rule, { access = "Deny", protocol = "*" }) }
  )
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = local.subnet_cidrs

  name                 = "snet-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "this" {
  for_each = local.subnet_cidrs

  name                = "nsg-${var.name_prefix}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.subnet_cidrs

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.nsg_rules

  name                        = each.key
  description                 = each.value.description
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.nsg].name
  priority                    = each.value.priority
  direction                   = "Inbound"
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_ranges     = each.value.ports
  source_address_prefix       = length(each.value.sources) == 1 ? each.value.sources[0] : null
  source_address_prefixes     = length(each.value.sources) > 1 ? each.value.sources : null
  destination_address_prefix  = "*"
}
