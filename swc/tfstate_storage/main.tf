module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name     = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-tfstate
  location = local.common.location
}

module "storage_account" {
  source = "github.com/VessyInc/modules//azurerm-storage-account?ref=v4.0.0"

  name                = substr("st${local.common.location_shortcode}${local.common.uniqueidentifier}${local.appname}", 0, 24)
  #stswcvessyinctfstate
  location            = local.common.location
  resource_group_name = module.resource_group.name

  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  public_network_access_enabled     = true
  shared_access_key_enabled         = false
  allow_nested_items_to_be_public   = false
  infrastructure_encryption_enabled = true

  network_rules = {
    bypass         = ["AzureServices"]
    default_action = "Allow"
  }

  role_assignments = {
    storage_blob_data_owner = {
      principal_id         = data.azurerm_client_config.current.object_id
      role_definition_name = "Storage Blob Data Owner"
    }
  }

  containers = {
    tfstate-storage = {
      name                  = "tfstate-storage"
      container_access_type = "private"
    }
    networking = {
      name                  = "networking"
      container_access_type = "private"
    }
  }
}