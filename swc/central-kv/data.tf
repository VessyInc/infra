data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "networking" {
  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_subnet" "central_kv" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-central-kv"
  virtual_network_name = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name  = data.azurerm_resource_group.networking.name
}
