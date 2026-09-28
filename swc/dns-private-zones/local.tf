locals {
  common  = yamldecode(file("../common.yml"))
  appname = "dns-private-zones"

  private_dns_zones = {
    aks = {
      zone_name = "privatelink.${local.common.location}.azmk8s.io"
    }
    kv = {
      zone_name = "privatelink.vaultcore.azure.net"
    }
    internal-vessyinc-com = {
      zone_name = "internal.vessyinc.com"
    }
  }
}
