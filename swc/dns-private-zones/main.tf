resource "azurerm_private_dns_zone" "this" {
  for_each = local.private_dns_zones

  name                = each.value.zone_name
  resource_group_name = data.azurerm_resource_group.networking.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = local.private_dns_zones

  name                  = "vnl-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${each.key}"
  resource_group_name   = data.azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = data.azurerm_virtual_network.networking.id
  registration_enabled  = false
}

moved {
  from = azurerm_private_dns_zone.aks
  to   = azurerm_private_dns_zone.this["aks"]
}

moved {
  from = azurerm_private_dns_zone.kv
  to   = azurerm_private_dns_zone.this["kv"]
}

moved {
  from = azurerm_private_dns_zone_virtual_network_link.aks
  to   = azurerm_private_dns_zone_virtual_network_link.this["aks"]
}

moved {
  from = azurerm_private_dns_zone_virtual_network_link.kv
  to   = azurerm_private_dns_zone_virtual_network_link.this["kv"]
}
