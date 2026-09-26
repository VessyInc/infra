locals {
  common  = yamldecode(file("../common.yml"))
  appname = "dns-private-zones"
}
