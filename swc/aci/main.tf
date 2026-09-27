module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-aci
  location = local.common.location
}

module "identity" {
  source = "github.com/VessyInc/modules//azurerm-user-assigned-identity?ref=v4.0.3"

  name                = "uai-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  location            = local.common.location
  resource_group_name = module.resource_group.name

  federated_identity_credentials = {}

  # lets the container group pull images from the ACR
  role_assignments = {
    acr_pull = {
      scope                            = data.azurerm_container_registry.acr.id
      role_definition_name             = "AcrPull"
      skip_service_principal_aad_check = false
    }
  }
}

module "container_group" {
  source = "github.com/VessyInc/modules//azurerm-container-group?ref=v4.0.4"

  name                = "ci-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  location            = local.common.location
  resource_group_name = module.resource_group.name

  os_type         = "Linux"
  ip_address_type = "Private"
  subnet_ids      = [data.azurerm_subnet.aci.id]
  restart_policy  = "Always"

  identity = {
    type         = "UserAssigned"
    identity_ids = [module.identity.id]
  }

  image_registry_credentials = {
    acr = {
      server                    = data.azurerm_container_registry.acr.login_server
      user_assigned_identity_id = module.identity.id
    }
  }

  containers = {
    cloudflared = {
      image  = "${data.azurerm_container_registry.acr.login_server}/cloudflaredtunnel:latest"
      cpu    = 1
      memory = 1.5

      commands = ["/usr/local/bin/cloudflared", "tunnel", "--loglevel", "debug", "--no-autoupdate", "run"]

      secure_environment_variables = {
        TUNNEL_TOKEN = data.azurerm_key_vault_secret.cloudflared_tunnel_token.value
      }

      ports = {
        https = {
          port     = 443
          protocol = "TCP"
        }
      }
    }
  }

  exposed_ports = {
    https = {
      port     = 443
      protocol = "TCP"
    }
  }

  role_assignments = {}

  depends_on = [module.identity]
}
