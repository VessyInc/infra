module "resource_group" {
  source = "github.com/VessyInc/modules//azurerm-resource-group?ref=v4.0.0"

  name = "rg-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #rg-swc-vessyinc-app-gw
  location = local.common.location
}

resource "azurerm_public_ip" "app_gw" {
  name                = "pip-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #pip-swc-vessyinc-app-gw
  resource_group_name = module.resource_group.name
  location            = local.common.location

  allocation_method = "Static"
  sku               = "Standard"
}

resource "azurerm_application_gateway" "this" {
  name                = "agw-${local.common.location_shortcode}-${local.common.uniqueidentifier}-${local.appname}"
  #agw-swc-vessyinc-app-gw
  resource_group_name = module.resource_group.name
  location            = local.common.location

  # Basic is the cheapest tier - it doesn't support a WAF policy, autoscaling,
  # or zones, so it's fixed at a single instance
  sku {
    name     = "Basic"
    tier     = "Basic"
    capacity = 1
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
    name     = "cert-app-gw-tls"
    data     = data.azurerm_key_vault_secret.argocd_tls_pfx.value
    password = data.azurerm_key_vault_secret.argocd_tls_pfx_password.value
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
}
