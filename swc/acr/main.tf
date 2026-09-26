module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-acr
  location = local.common.location
}

resource "azurerm_container_registry" "acr" {
  name = "${local.appname}${local.common.location_shortcode}${local.common.uniqueidentifier}"
  #acrswcvessyinc
  location            = local.common.location
  resource_group_name = module.resource_group.name

  sku                           = "Basic"
  admin_enabled                 = false
  public_network_access_enabled = true
}

resource "azurerm_role_assignment" "acr" {
  for_each = toset(["AcrPush", "AcrPull", "AcrDelete"])

  scope                = azurerm_container_registry.acr.id
  role_definition_name = each.value
  principal_id         = "842b9417-8fb0-4de5-b951-27c5a4678162"
}
