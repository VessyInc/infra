data "azurerm_resource_group" "networking" {
  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_virtual_network" "networking" {
  name                = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name = data.azurerm_resource_group.networking.name
}
