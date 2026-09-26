locals {
  common  = yamldecode(file("../common.yml"))
  appname = "aci"
}
