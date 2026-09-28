data "azurerm_client_config" "current" {}

data "azurerm_subnet" "aks" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-aks"
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

data "azurerm_key_vault" "central_kv" {
  name                = "kv${local.common.location_shortcode}${local.common.uniqueidentifier}central-kv"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-central-kv"
}

data "azurerm_container_registry" "acr" {
  name                = "acr${local.common.location_shortcode}${local.common.uniqueidentifier}"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-acr"
}
