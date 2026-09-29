data "azurerm_subnet" "app_gw" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-app-gw"
  virtual_network_name = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name  = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_key_vault" "central_kv" {
  name                = "kv${local.common.location_shortcode}${local.common.uniqueidentifier}central-kv"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-central-kv"
}

data "azurerm_key_vault_certificate" "argocd_tls" {
  name         = "tls-argocd"
  key_vault_id = data.azurerm_key_vault.central_kv.id
}
