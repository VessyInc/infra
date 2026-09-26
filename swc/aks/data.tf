data "azurerm_client_config" "current" {}

data "azurerm_subnet" "aks" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-aks"
  virtual_network_name = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name  = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_subnet" "aks_pe" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-aks-pe"
  virtual_network_name = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name  = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_virtual_network" "networking" {
  name                = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${local.common.location}.azmk8s.io"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}
