module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-aks
  location = local.common.location
}

module "control_plane_identity" {
  source = "github.com/VessyInc/modules//azurerm-user-assigned-identity?ref=v4.0.3"

  name                = "uai-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-control-plane"
  location            = local.common.location
  resource_group_name = module.resource_group.name

  federated_identity_credentials = {}

  role_assignments = {
    network_contributor = {
      scope                            = data.azurerm_subnet.aks.id
      role_definition_name             = "Network Contributor"
      skip_service_principal_aad_check = false
    }
    private_dns_zone_reader = {
      scope                            = data.azurerm_private_dns_zone.aks.id
      role_definition_name             = "Reader"
      skip_service_principal_aad_check = false
    }
    private_dns_zone_contributor = {
      scope                            = data.azurerm_private_dns_zone.aks.id
      role_definition_name             = "Private DNS Zone Contributor"
      skip_service_principal_aad_check = false
    }
  }
}

module "workload_identity" {
  source = "github.com/VessyInc/modules//azurerm-user-assigned-identity?ref=v4.0.3"

  name                = "uai-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-workload"
  location            = local.common.location
  resource_group_name = module.resource_group.name
  role_assignments    = {}
  # add one entry per workload once a real namespace/service account exists, e.g.:
  # app = {
  #   issuer   = module.aks.oidc_issuer_url
  #   subject  = "system:serviceaccount:<namespace>:<service-account>"
  #   audience = ["api://AzureADTokenExchange"]
  #   name     = "app"
  # }
  federated_identity_credentials = {}
}

module "key_vault" {
  source = "github.com/VessyInc/modules//azurerm-key-vault?ref=v4.0.2"

  name = "kv-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #kv-swc-vessyinc-aks
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

  # private endpoint sits in the dedicated PE subnet - no private DNS zone module
  # exists in this repo yet, so DNS resolution to the private IP isn't wired up
  private_endpoints = {
    kv = {
      name      = "pe-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-kv"
      subnet_id = data.azurerm_subnet.aks_pe.id
      private_service_connection = {
        is_manual_connection = false
        name                 = "psc-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-kv"
        subresource_names    = ["vault"]
      }
    }
  }

  # pods reach Key Vault through this identity via workload identity federation
  role_assignments = {
    workload_identity = {
      principal_id         = module.workload_identity.principal_id
      role_definition_name = "Key Vault Secrets User"
    }
  }
}

module "aks" {
  source = "github.com/VessyInc/modules//azurerm-kubernetes-cluster?ref=v4.0.2"

  name                = "aks-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  location            = local.common.location
  resource_group_name = module.resource_group.name
  dns_prefix          = "${local.appname}-${local.common.uniqueidentifier}"

  node_resource_group = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-nodes"

  sku_tier                  = "Free"
  support_plan              = "KubernetesOfficial"
  automatic_upgrade_channel = null
  node_os_upgrade_channel   = "NodeImage"

  private_cluster_enabled             = true
  private_cluster_public_fqdn_enabled = false
  private_dns_zone_id                 = data.azurerm_private_dns_zone.aks.id

  identity = {
    type         = "UserAssigned"
    identity_ids = [module.control_plane_identity.id]
  }

  default_node_pool = {
    name                         = "system"
    vm_size                      = "Standard_B2s_v2"
    vnet_subnet_id               = data.azurerm_subnet.aks.id
    auto_scaling_enabled         = true
    min_count                    = 1
    max_count                    = 2
    node_count                   = 1
    max_pods                     = 50
    only_critical_addons_enabled = true # keeps workloads off the system pool; add workload pools via node_pools
    os_disk_type                 = "Managed"
    os_sku                       = "AzureLinux"
    type                         = "VirtualMachineScaleSets"
    scale_down_mode              = "Delete"
    temporary_name_for_rotation  = "systemtmp"

    upgrade_settings = {
      max_surge = "50%"
    }
  }

  node_pools = {} # no additional (user) node pools yet

  network_profile = {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting"
    pod_cidr            = "192.168.0.0/16" # does not overlap the 10.0.0.0/8 vnet
    service_cidr        = "172.16.0.0/16"  # does not overlap the vnet or pod_cidr
    dns_service_ip      = "172.16.0.10"
    ip_versions         = ["IPv4"]
  }

  role_based_access_control_enabled = true
  local_account_disabled            = true
  
  azure_active_directory_role_based_access_control = {
    admin_group_object_ids = ["26c170fc-3976-46be-95a7-dff9e9533455"]
    azure_rbac_enabled     = false
    tenant_id              = data.azurerm_client_config.current.tenant_id
  }
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 168
  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }
  key_management_service = null # needs a Key Vault key for etcd (KMS) encryption
  bootstrap_profile = {
    artifact_source       = "Direct"
    container_registry_id = null
  }

  maintenance_window = null
  maintenance_window_auto_upgrade = {
    frequency    = "Weekly"
    interval     = 1
    duration     = 4
    day_of_week  = "Sunday"
    start_time   = "02:00"
    utc_offset   = "+00:00"
    day_of_month = null
    start_date   = null
    week_index   = null
    not_allowed  = []
  }
  maintenance_window_node_os = {
    frequency   = "Weekly"
    interval    = 1
    duration    = 4
    day_of_week = "Sunday"
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }

  auto_scaler_profile = null

  node_resource_group_role_assignments = {}
  role_assignments                     = {}

  # wait for the control plane identity's Private DNS Zone Contributor role assignment
  # to exist (and its RBAC to propagate) before AKS tries to write records into the zone
  depends_on = [module.control_plane_identity]
}
