resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${local.common.location}.azmk8s.io"
  resource_group_name = data.azurerm_resource_group.networking.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "aks" {
  name                  = "vnl-${local.common.location_shortcode}-${local.common.uniqueidentifier}-aks"
  resource_group_name   = data.azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.aks.name
  virtual_network_id    = data.azurerm_virtual_network.networking.id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone" "kv" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.networking.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv" {
  name                  = "vnl-${local.common.location_shortcode}-${local.common.uniqueidentifier}-kv"
  resource_group_name   = data.azurerm_resource_group.networking.name
  private_dns_zone_name = azurerm_private_dns_zone.kv.name
  virtual_network_id    = data.azurerm_virtual_network.networking.id
  registration_enabled  = false
}
