locals {
  common  = yamldecode(file("../common.yml"))
  appname = "acr"
}
