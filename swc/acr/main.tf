module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-acr
  location = local.common.location
}

# no azurerm-container-registry module exists in VessyInc/modules yet - swap to it once one does
resource "azurerm_container_registry" "acr" {
  name = "${local.appname}${local.common.location_shortcode}${local.common.uniqueidentifier}"
  #acrswcvessyinc
  location            = local.common.location
  resource_group_name = module.resource_group.name

  sku                           = "Basic"
  admin_enabled                 = false
  public_network_access_enabled = true
}
