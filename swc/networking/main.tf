module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-networking
  location = local.common.location
}

module "virtual_network" {
  source = "github.com/VessyInc/modules//azurerm-virtual-network?ref=v4.0.0"

  name                = "vnet-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  resource_group_name = module.resource_group.name
  location            = local.common.location

  address_space = ["10.0.0.0/8"]

  subnets = [
    {
      name             = "aks"
      address_prefixes = ["10.0.0.0/16"]
    }
  ]

  nsg_rules = local.nsg_rules
}