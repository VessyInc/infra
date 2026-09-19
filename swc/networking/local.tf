locals {
  common  = yamldecode(file("../common.yml"))
  appname = "networking"

  nsg_rules = merge([
    for f in fileset(path.module, "network_security_group/*.yml") :
    yamldecode(file("${path.module}/${f}"))
  ]...)
}