data "azurerm_subnet" "app_gw" {
  name                 = "snet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-app-gw"
  virtual_network_name = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
  resource_group_name  = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-networking"
}

data "azurerm_key_vault" "central_kv" {
  name                = "kv${local.common.location_shortcode}${local.common.uniqueidentifier}central-kv"
  resource_group_name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-central-kv"
}

# Basic SKU can't use key_vault_secret_id (Key Vault-integrated certs are v2/WAF_v2
# only), so the PFX is uploaded directly via ssl_certificate.data/.password instead -
# still sourced from central_kv, just read at apply time rather than polled live
data "azurerm_key_vault_secret" "argocd_tls_pfx" {
  name         = "argocd-tls-pfx"
  key_vault_id = data.azurerm_key_vault.central_kv.id
}

data "azurerm_key_vault_secret" "argocd_tls_pfx_password" {
  name         = "argocd-tls-pfx-password"
  key_vault_id = data.azurerm_key_vault.central_kv.id
}
