data "azurerm_subnet" "wekan" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  virtual_network_name = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name  = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_private_dns_zone" "mongo_vcore" {
  name                = "privatelink.mongocluster.cosmos.azure.com"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_key_vault" "central_kv" {
  name                = "kv${local.common.location_shortcode}${local.common.uniqueidentifier}central-kv"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-central-kv"
}

data "azurerm_key_vault_secret" "mongo_administrator_password" {
  name         = "wekan-mongo-administrator-password"
  key_vault_id = data.azurerm_key_vault.central_kv.id
}
