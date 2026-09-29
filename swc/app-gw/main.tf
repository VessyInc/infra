module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-app-gw
  location = local.common.location
}

module "cert_identity" {
  source = "github.com/VessyInc/modules//azurerm-user-assigned-identity?ref=v4.0.3"

  name                = "uai-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}-cert"
  location            = local.common.location
  resource_group_name = module.resource_group.name

  federated_identity_credentials = {}

  # lets the Application Gateway read TLS certificates stored as Key Vault secrets
  role_assignments = {
    kv_secrets_user = {
      scope                            = data.azurerm_key_vault.central_kv.id
      role_definition_name             = "Key Vault Secrets User"
      skip_service_principal_aad_check = false
    }
  }
}

resource "azurerm_public_ip" "app_gw" {
  name                = "pip-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #pip-swc-vessyinc-app-gw
  resource_group_name = module.resource_group.name
  location            = local.common.location

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_web_application_firewall_policy" "app_gw" {
  name                = "waf-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #waf-swc-vessyinc-app-gw
  resource_group_name = module.resource_group.name
  location            = local.common.location

  policy_settings {
    enabled = true
    mode    = "Prevention"
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_application_gateway" "this" {
  name                = "agw-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #agw-swc-vessyinc-app-gw
  resource_group_name = module.resource_group.name
  location            = local.common.location

  firewall_policy_id = azurerm_web_application_firewall_policy.app_gw.id

  # WAF_v2 is required to attach a Web Application Firewall Policy - Basic/Standard_v2
  # don't support one, so this isn't the cheapest tier despite the WAF policy above
  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = 1
    max_capacity = 2
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [module.cert_identity.id]
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.app_gw.id
  }

  frontend_ip_configuration {
    name                 = "Frontend-Public-IP"
    public_ip_address_id = azurerm_public_ip.app_gw.id
  }

  frontend_ip_configuration {
    name                          = "Frontend-Private-IP"
    private_ip_address            = local.agw_frontend_private_ip
    private_ip_address_allocation = "Static"
    subnet_id                     = data.azurerm_subnet.app_gw.id
  }

  frontend_port {
    name = "port-443"
    port = 443
  }

  ssl_certificate {
    name                = "cert-app-gw-tls"
    key_vault_secret_id = data.azurerm_key_vault_certificate.argocd_tls.secret_id
  }

  backend_address_pool {
    name = "default"
  }

  backend_http_settings {
    name                  = "https-settings"
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
  }

  http_listener {
    name                           = "listener-https"
    frontend_ip_configuration_name = "Frontend-Public-IP"
    frontend_port_name             = "port-443"
    protocol                       = "Https"
    ssl_certificate_name           = "cert-app-gw-tls"
    host_name                      = "argocd.vessyinc.com"
  }

  request_routing_rule {
    name                       = "rule-https"
    rule_type                  = "Basic"
    http_listener_name         = "listener-https"
    backend_address_pool_name  = "default"
    backend_http_settings_name = "https-settings"
    priority                   = 100
  }

  depends_on = [module.cert_identity]
}
