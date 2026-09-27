module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-central-kv
  location = local.common.location
}

module "key_vault" {
  source = "github.com/VessyInc/modules//azurerm-key-vault?ref=v4.0.2"

  name = "kv${local.common.location_shortcode}${local.common.uniqueidentifier}${local.appname}"
  #kvswcvessyinccentral-kv
  location            = local.common.location
  resource_group_name = module.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                        = "standard"
  rbac_authorization_enabled      = true
  access_policies                 = {}
  purge_protection_enabled        = true
  soft_delete_retention_days      = 90
  public_network_access_enabled   = false
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false

  network_acls = {
    bypass         = "AzureServices"
    default_action = "Deny"
  }

  private_endpoints = {
    kv = {
      name      = "pe-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-kv"
      subnet_id = data.azurerm_subnet.central_kv.id
      private_service_connection = {
        is_manual_connection = false
        name                 = "psc-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-kv"
        subresource_names    = ["vault"]
      }
    }
  }

  role_assignments = {}
}
