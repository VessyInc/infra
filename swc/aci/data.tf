data "azurerm_subnet" "aci" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-aci"
  virtual_network_name = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name  = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_container_registry" "acr" {
  name                = "acr${local.common.location_shortcode}${local.common.uniqueidentifier}"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-acr"
}
