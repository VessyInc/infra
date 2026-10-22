module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-wekan
  location = local.common.location
}

module "mongo_cluster" {
  source = "github.com/VessyInc/modules//azurerm-cosmosdb-mongodb-vcore?ref=v4.0.6"

  name = "mongo-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #mongo-swc-vessyinc-wekan
  location            = local.common.location
  resource_group_name = module.resource_group.name

  create_mode            = "Default"
  mongo_version          = "7.0"
  compute_tier           = "M10"
  storage_size_in_gb     = 32
  storage_type           = "PremiumSSD"
  shard_count            = 1
  high_availability_mode = "Disabled"

  authentication_methods = ["NativeAuth"]
  administrator_username = "wekanadmin"
  administrator_password = data.azurerm_key_vault_secret.mongo_administrator_password.value

  public_network_access = "Disabled"
  data_api_mode_enabled = false

  firewall_rules = {}

  private_endpoints = {
    mongo = {
      name      = "pe-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-mongo"
      subnet_id = data.azurerm_subnet.wekan.id
      private_service_connection = {
        is_manual_connection = false
        name                 = "psc-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-mongo"
        subresource_names    = ["MongoCluster"]
      }
      private_dns_zone_group = {
        name                 = "pdzg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-mongo"
        private_dns_zone_ids = [data.azurerm_private_dns_zone.mongo_vcore.id]
      }
    }
  }

  role_assignments = {}
}
